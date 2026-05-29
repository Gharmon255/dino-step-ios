//
//  WatchConnectivityReceiver.swift
//  Dino Step Watch Watch App
//

import Combine
import Foundation

#if os(watchOS)
import WatchConnectivity

@MainActor
final class WatchConnectivityReceiver: NSObject, ObservableObject {
    static let shared = WatchConnectivityReceiver()

    @Published private(set) var payload: WatchGameStatePayload?
    @Published private(set) var syncStatus = "Waiting for iPhone"
    @Published private(set) var hasReceivedPayload = false

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else {
            syncStatus = "Waiting for iPhone"
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()

        let context = session.receivedApplicationContext
        if !context.isEmpty {
            apply(context: context)
        }
    }

    private func apply(context: [String: Any]) {
        guard let payload = WatchGameStatePayload.decode(from: context) else {
            Self.log("Failed to decode application context")
            return
        }

        self.payload = payload
        hasReceivedPayload = true
        syncStatus = "Synced"
        Self.log("Received payload: \(payload.displayName) @ \(payload.updatedAt)")
    }

    nonisolated private static func log(_ message: String) {
        print("[WatchConnectivityReceiver] \(message)")
    }
}

extension WatchConnectivityReceiver: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            if let error {
                Self.log("Activation failed: \(error.localizedDescription)")
            }

            let context = session.receivedApplicationContext
            if !context.isEmpty {
                apply(context: context)
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            apply(context: applicationContext)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            apply(context: message)
        }
    }
}
#endif
