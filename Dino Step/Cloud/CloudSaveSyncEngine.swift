//
//  CloudSaveSyncEngine.swift
//  Dino Step
//

import Combine
import Foundation

@MainActor
final class CloudSaveSyncEngine: ObservableObject {
    @Published private(set) var uiState: CloudAccountUiState

    var onApplyCloudSave: ((GameStateSnapshot) -> Void)?

    private let config: SupabaseConfig
    private let httpClient: SupabaseHTTPClient
    private let sessionStore: CloudSessionStore
    private let syncPreferences: CloudSyncPreferences
    private let persistenceStore: GamePersistenceStore
    private let appleSignIn = AppleSignInCoordinator()
    private let googleOAuth = GoogleOAuthCoordinator()
    private var debounceTask: Task<Void, Never>?

    init(
        config: SupabaseConfig = .shared,
        httpClient: SupabaseHTTPClient? = nil,
        sessionStore: CloudSessionStore = CloudSessionStore(),
        syncPreferences: CloudSyncPreferences = CloudSyncPreferences(),
        persistenceStore: GamePersistenceStore
    ) {
        self.config = config
        self.httpClient = httpClient ?? SupabaseHTTPClient(config: config)
        self.sessionStore = sessionStore
        self.syncPreferences = syncPreferences
        self.persistenceStore = persistenceStore
        self.uiState = CloudAccountUiState(
            isConfigured: config.isConfigured,
            syncStatus: config.isConfigured ? .signedOut : .unavailable,
            lastBackedUpAtMillis: syncPreferences.lastBackedUpAtMillis
        )
    }

    func refreshSessionOnLaunch(localSnapshot: GameStateSnapshot) {
        guard config.isConfigured else { return }
        Task {
            guard let session = await restoreSession() else {
                updateSignedInState(nil)
                return
            }
            do {
                let cloudRow = try await httpClient.fetchGameSave(authSession: session)
                if let cloudRow, CloudSaveMapper.isLocalEmpty(localSnapshot) {
                    applyCloudSnapshot(cloudRow.save)
                    if let restored = CloudSaveMapper.toSnapshot(cloudRow.save) {
                        onApplyCloudSave?(restored)
                    }
                }
                updateSignedInState(session)
            } catch {
                updateSignedInState(session)
            }
        }
    }

    func signInWithApple(localSnapshot: GameStateSnapshot) {
        guard config.isConfigured else { return }
        uiState.syncStatus = .syncing
        uiState.lastError = nil
        Task {
            do {
                let idToken = try await appleSignIn.signIn()
                let session = try await httpClient.signInWithIdToken(provider: "apple", idToken: idToken)
                sessionStore.saveSession(session)
                try await reconcileAfterSignIn(session: session, localSnapshot: localSnapshot)
            } catch {
                uiState.syncStatus = .error
                uiState.lastError = error.localizedDescription
            }
        }
    }

    func signInWithGoogle(localSnapshot: GameStateSnapshot) {
        guard config.isConfigured else { return }
        uiState.syncStatus = .syncing
        uiState.lastError = nil
        Task {
            do {
                let session = try await googleOAuth.signIn(config: config, httpClient: httpClient)
                sessionStore.saveSession(session)
                try await reconcileAfterSignIn(session: session, localSnapshot: localSnapshot)
            } catch {
                uiState.syncStatus = .error
                uiState.lastError = error.localizedDescription
            }
        }
    }

    func signOut() {
        sessionStore.clear()
        uiState = initialUiState()
        uiState.syncStatus = .signedOut
    }

    func schedulePush(localSnapshot: GameStateSnapshot) {
        guard config.isConfigured, let session = sessionStore.loadSession() else { return }
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            await pushSnapshot(session: session, localSnapshot: localSnapshot)
        }
    }

    func exportLocalJson(localSnapshot: GameStateSnapshot) -> String {
        let cloud = CloudSaveMapper.toCloud(
            snapshot: localSnapshot,
            revision: syncPreferences.nextRevision(),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
        let data = try? JSONEncoder().encode(cloud)
        return String(data: data ?? Data(), encoding: .utf8) ?? "{}"
    }

    func resolveConflictKeepLocal(localSnapshot: GameStateSnapshot) {
        guard case .localVsCloud = uiState.pendingConflict else { return }
        uiState.pendingConflict = nil
        guard let session = sessionStore.loadSession() else { return }
        Task {
            await pushSnapshot(session: session, localSnapshot: localSnapshot)
        }
    }

    func resolveConflictUseCloud() async -> GameStateSnapshot? {
        guard case let .localVsCloud(_, cloud) = uiState.pendingConflict else { return nil }
        uiState.pendingConflict = nil
        guard let snapshot = CloudSaveMapper.toSnapshot(cloud) else { return nil }
        persistenceStore.replaceSnapshot(snapshot)
        syncPreferences.localRevision = cloud.revision
        syncPreferences.lastBackedUpAtMillis = Int64(Date().timeIntervalSince1970 * 1000)
        uiState.lastBackedUpAtMillis = syncPreferences.lastBackedUpAtMillis
        uiState.syncStatus = .backedUp
        onApplyCloudSave?(snapshot)
        return snapshot
    }

    func dismissConflict() {
        uiState.pendingConflict = nil
    }

    private func reconcileAfterSignIn(session: CloudSession, localSnapshot: GameStateSnapshot) async throws {
        let cloudRow = try await httpClient.fetchGameSave(authSession: session)
        if cloudRow == nil {
            await pushSnapshot(session: session, localSnapshot: localSnapshot)
            updateSignedInState(session)
            return
        }
        if CloudSaveMapper.isLocalEmpty(localSnapshot) {
            applyCloudSnapshot(cloudRow!.save)
            if let restored = CloudSaveMapper.toSnapshot(cloudRow!.save) {
                onApplyCloudSave?(restored)
            }
            updateSignedInState(session)
            return
        }
        if cloudRow!.save.revision == syncPreferences.localRevision {
            updateSignedInState(session)
            return
        }
        let localCloud = CloudSaveMapper.toCloud(
            snapshot: localSnapshot,
            revision: syncPreferences.localRevision,
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
        uiState.signedInEmail = session.email
        uiState.signedInProvider = session.provider
        uiState.syncStatus = .backedUp
        uiState.pendingConflict = .localVsCloud(local: localCloud, cloud: cloudRow!.save)
    }

    private func pushSnapshot(session: CloudSession, localSnapshot: GameStateSnapshot) async {
        uiState.syncStatus = .syncing
        uiState.lastError = nil
        do {
            let revision = syncPreferences.nextRevision()
            let updatedAt = ISO8601DateFormatter().string(from: Date())
            let cloud = CloudSaveMapper.toCloud(
                snapshot: localSnapshot,
                revision: revision,
                updatedAt: updatedAt
            )
            let row = CloudSaveRow(
                userId: session.userId,
                schemaVersion: cloud.schemaVersion,
                revision: cloud.revision,
                save: cloud,
                updatedAt: updatedAt
            )
            try await httpClient.upsertGameSave(authSession: session, row: row)
            syncPreferences.lastBackedUpAtMillis = Int64(Date().timeIntervalSince1970 * 1000)
            uiState.syncStatus = .backedUp
            uiState.lastBackedUpAtMillis = syncPreferences.lastBackedUpAtMillis
            uiState.lastError = nil
        } catch {
            uiState.syncStatus = .error
            uiState.lastError = error.localizedDescription
        }
    }

    private func applyCloudSnapshot(_ cloud: CloudGameSave) {
        guard let snapshot = CloudSaveMapper.toSnapshot(cloud) else { return }
        persistenceStore.replaceSnapshot(snapshot)
        syncPreferences.localRevision = cloud.revision
        syncPreferences.lastBackedUpAtMillis = Int64(Date().timeIntervalSince1970 * 1000)
    }

    private func restoreSession() async -> CloudSession? {
        guard let existing = sessionStore.loadSession() else { return nil }
        do {
            let refreshed = try await httpClient.refreshSession(refreshToken: existing.refreshToken)
            sessionStore.saveSession(refreshed)
            return refreshed
        } catch {
            sessionStore.clear()
            return nil
        }
    }

    private func updateSignedInState(_ session: CloudSession?) {
        guard let session else {
            uiState = initialUiState()
            uiState.syncStatus = .signedOut
            return
        }
        uiState.syncStatus = .backedUp
        uiState.signedInEmail = session.email
        uiState.signedInProvider = session.provider
        uiState.lastBackedUpAtMillis = syncPreferences.lastBackedUpAtMillis
        uiState.lastError = nil
    }

    private func initialUiState() -> CloudAccountUiState {
        CloudAccountUiState(
            isConfigured: config.isConfigured,
            syncStatus: config.isConfigured ? .signedOut : .unavailable,
            lastBackedUpAtMillis: syncPreferences.lastBackedUpAtMillis
        )
    }
}
