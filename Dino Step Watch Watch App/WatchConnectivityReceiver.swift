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
    static let requestSyncMessageKey = WatchConnectivityKeys.requestSyncMessageKey

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
        } else if let cached = WatchComplicationSharedStore.load() {
            payload = cached
            hasReceivedPayload = true
            syncStatus = "Cached"
            refreshComplications()
        }

        requestSyncFromPhone()
    }

    func refreshComplications() {
        guard let payload else { return }
        WatchComplicationSharedStore.save(payload)
        WatchComplicationTimelineRefresher.reloadAll()
    }

    func requestSyncFromPhone() {
        guard WCSession.isSupported() else { return }

        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else {
            Self.log("Skipping phone sync request — session not reachable")
            return
        }

        session.sendMessage([Self.requestSyncMessageKey: true], replyHandler: { reply in
            Task { @MainActor in
                self.apply(context: reply)
            }
        }, errorHandler: { error in
            Self.log("Phone sync request failed: \(error.localizedDescription)")
        })
    }

    private func apply(context: [String: Any]) {
        guard let payload = WatchGameStatePayload.decode(from: context) else {
            Self.log("Failed to decode watch payload")
            return
        }

        let payloadChanged = self.payload != payload
        self.payload = payload
        hasReceivedPayload = true
        syncStatus = "Synced"

        if payloadChanged {
            WatchComplicationSharedStore.save(payload)
            WatchComplicationTimelineRefresher.reloadAll()
        }

        Self.log(
            "Received \(payload.creatureName) \(payload.stage) " +
            "(species: \(payload.speciesId ?? "nil"), steps: \(payload.currentSteps))"
        )
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
            } else {
                requestSyncFromPhone()
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

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            if session.isReachable {
                requestSyncFromPhone()
            }
        }
    }
}
#endif
