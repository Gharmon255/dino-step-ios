//
//  AccountBackupCard.swift
//  Dino Step
//

import SwiftUI

enum CloudBackupFeatures {
    static let signInEnabled = true
    static let googleSignInEnabled = false
}

struct AccountBackupCard: View {
    @ObservedObject var cloudSyncEngine: CloudSaveSyncEngine
    let onSignInWithApple: () -> Void
    let onSignInWithGoogle: () -> Void
    let onSignOut: () -> Void
    let onExportSave: () -> String

    var body: some View {
        GameCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Account & backup")
                    .font(.headline)

                if !CloudBackupFeatures.signInEnabled {
                    Text("Sign in to back up progress across devices. Gameplay works offline without an account.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Coming soon")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.teal)
                } else if !cloudSyncEngine.uiState.isConfigured {
                    Text("Cloud backup is not configured in this build.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if let email = cloudSyncEngine.uiState.signedInEmail {
                    signedInContent(email: email)
                } else {
                    signedOutContent
                }

                Button("Export local save") {
                    exportText = onExportSave()
                    showExportSheet = true
                }
                .buttonStyle(.bordered)
            }
        }
        .sheet(isPresented: $showExportSheet) {
            NavigationStack {
                ScrollView {
                    Text(exportText)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                }
                .navigationTitle("Local save backup")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(item: exportText)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func signedInContent(email: String) -> some View {
        Text("Signed in as \(email)")
            .font(.subheadline)
        if let provider = cloudSyncEngine.uiState.signedInProvider {
            Text("Provider: \(provider)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        if let status = backupStatusText {
            Text(status)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        if cloudSyncEngine.uiState.syncStatus == .syncing {
            ProgressView()
        }
        if let error = cloudSyncEngine.uiState.lastError {
            Text(error)
                .font(.caption)
                .foregroundStyle(.red)
        }
        Button("Sign out", action: onSignOut)
            .buttonStyle(.bordered)
    }

    @ViewBuilder
    private var signedOutContent: some View {
        Text("Sign in to back up your dinosaurs. If the app updates, your collection can be restored from the cloud.")
            .font(.subheadline)
            .foregroundStyle(.secondary)

        Button("Sign in with Apple", action: onSignInWithApple)
            .buttonStyle(.borderedProminent)
            .disabled(cloudSyncEngine.uiState.syncStatus == .syncing)

        if CloudBackupFeatures.googleSignInEnabled {
            Button("Sign in with Google", action: onSignInWithGoogle)
                .buttonStyle(.bordered)
                .disabled(cloudSyncEngine.uiState.syncStatus == .syncing)
        }

        if cloudSyncEngine.uiState.syncStatus == .syncing {
            ProgressView()
        }
        if let error = cloudSyncEngine.uiState.lastError {
            Text(error)
                .font(.caption)
                .foregroundStyle(.red)
        }
    }

    @State private var showExportSheet = false
    @State private var exportText = ""

    private var backupStatusText: String? {
        switch cloudSyncEngine.uiState.syncStatus {
        case .syncing:
            return "Backing up…"
        case .backedUp:
            if let millis = cloudSyncEngine.uiState.lastBackedUpAtMillis {
                let date = Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
                return "Last backed up \(date.formatted(date: .abbreviated, time: .shortened))"
            }
            return "Backup enabled"
        case .error:
            return "Backup error"
        case .signedOut, .unavailable:
            return nil
        }
    }
}
