//
//  PhoneWatchConnectivityManager.swift
//  Dino Step
//

import Combine
import Foundation

#if os(iOS)
import WatchConnectivity

@MainActor
final class PhoneWatchConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneWatchConnectivityManager()

    @Published private(set) var isSupported = WCSession.isSupported()
    @Published private(set) var activationState: WCSessionActivationState = .notActivated
    @Published private(set) var isPaired = false
    @Published private(set) var isWatchAppInstalled = false
    @Published private(set) var isReachable = false
    @Published private(set) var lastSyncMessage: String?
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var lastSentPayload: WatchGameStatePayload?

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else {
            isSupported = false
            lastSyncMessage = "WatchConnectivity not supported"
            return
        }

        isSupported = true
        let session = WCSession.default
        session.delegate = self
        session.activate()
        refreshSessionStatus(from: session)
    }

    func send(payload: WatchGameStatePayload) {
        guard WCSession.isSupported() else {
            lastSyncMessage = "WatchConnectivity not supported"
            return
        }

        let session = WCSession.default

        guard session.activationState == .activated else {
            lastSyncMessage = "Watch session not activated"
            return
        }

        guard session.isPaired else {
            lastSyncMessage = "No paired Apple Watch"
            return
        }

        guard session.isWatchAppInstalled else {
            lastSyncMessage = "Watch app not installed"
            return
        }

        let context = payload.applicationContext()
        guard !context.isEmpty else {
            lastSyncMessage = "Failed to encode watch payload"
            return
        }

        do {
            try session.updateApplicationContext(context)
            lastSentPayload = payload
            lastSyncDate = Date()
            lastSyncMessage = "Sent state to watch"

            if session.isReachable {
                session.sendMessage(context, replyHandler: nil) { error in
                    Task { @MainActor in
                        Self.log("sendMessage failed: \(error.localizedDescription)")
                        self.lastSyncMessage = "Context sent; message failed: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            Self.log("updateApplicationContext failed: \(error.localizedDescription)")
            lastSyncMessage = "Watch sync failed: \(error.localizedDescription)"
        }
    }

    var activationStateLabel: String {
        switch activationState {
        case .notActivated: "Not Activated"
        case .inactive: "Inactive"
        case .activated: "Activated"
        @unknown default: "Unknown"
        }
    }

    private func refreshSessionStatus(from session: WCSession) {
        activationState = session.activationState
        isPaired = session.isPaired
        isWatchAppInstalled = session.isWatchAppInstalled
        isReachable = session.isReachable
    }

    nonisolated private static func log(_ message: String) {
        print("[PhoneWatchConnectivityManager] \(message)")
    }
}

extension PhoneWatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            if let error {
                Self.log("Activation failed: \(error.localizedDescription)")
                lastSyncMessage = "Watch activation failed: \(error.localizedDescription)"
            } else {
                Self.log("Activation complete: \(activationState.rawValue)")
            }
            refreshSessionStatus(from: session)
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        Task { @MainActor in
            refreshSessionStatus(from: session)
        }
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        Task { @MainActor in
            refreshSessionStatus(from: session)
            session.activate()
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            refreshSessionStatus(from: session)
        }
    }
}
#endif
