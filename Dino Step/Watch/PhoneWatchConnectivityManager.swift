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

    var payloadProvider: (@MainActor () -> WatchGameStatePayload?)?

    private var pendingPayload: WatchGameStatePayload?

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
        pendingPayload = payload
        deliver(payload: payload)
    }

    func resendLatestPayload() {
        if let pendingPayload {
            deliver(payload: pendingPayload)
            return
        }

        if let payload = payloadProvider?() {
            deliver(payload: payload)
        }
    }

    private func deliver(payload: WatchGameStatePayload) {
        guard WCSession.isSupported() else {
            lastSyncMessage = "WatchConnectivity not supported"
            return
        }

        let session = WCSession.default

        guard session.activationState == .activated else {
            lastSyncMessage = "Watch session not activated — queued"
            Self.log("Queued payload until watch session activates")
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
            pendingPayload = payload
            lastSentPayload = payload
            lastSyncDate = Date()
            lastSyncMessage = "Sent \(payload.creatureName) \(payload.stage) to watch"

            if session.isReachable {
                session.sendMessage(context, replyHandler: nil) { error in
                    Task { @MainActor in
                        Self.log("sendMessage failed: \(error.localizedDescription)")
                        self.lastSyncMessage = "Context sent; message failed: \(error.localizedDescription)"
                    }
                }
            }

            Self.log(
                "Sent \(payload.creatureName) \(payload.stage) " +
                "(species: \(payload.speciesId ?? "nil"), steps: \(payload.currentSteps))"
            )
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

    private func deliverPendingPayloadIfPossible(from session: WCSession) {
        refreshSessionStatus(from: session)
        guard session.activationState == .activated else { return }

        if let pendingPayload {
            deliver(payload: pendingPayload)
            return
        }

        if let payload = payloadProvider?() {
            deliver(payload: payload)
        }
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
            deliverPendingPayloadIfPossible(from: session)
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
            deliverPendingPayloadIfPossible(from: session)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Task { @MainActor in
            if message[WatchConnectivityKeys.requestSyncMessageKey] as? Bool == true {
                let payload = payloadProvider?() ?? lastSentPayload ?? pendingPayload
                if let payload {
                    replyHandler(payload.applicationContext())
                    Self.log("Replied to watch sync request with \(payload.creatureName) \(payload.stage)")
                } else {
                    replyHandler([:])
                    Self.log("Watch sync request received but no payload available")
                }
            }
        }
    }
}
#endif
