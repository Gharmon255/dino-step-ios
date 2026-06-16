//
//  WatchWidgetConnectivityBootstrap.swift
//  Dino Step Watch Widgets
//

import Foundation
import WatchConnectivity

/// Keeps the widget extension subscribed to phone → watch application context updates.
final class WatchWidgetConnectivityBootstrap: NSObject, WCSessionDelegate {
    static let shared = WatchWidgetConnectivityBootstrap()

    private override init() {
        super.init()
    }

    func prepareSession() {
        guard WCSession.isSupported() else { return }

        let session = WCSession.default
        if session.delegate == nil {
            session.delegate = self
        }

        if session.activationState == .notActivated {
            session.activate()
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
#if DEBUG
        if let error {
            print("[WatchWidgetConnectivityBootstrap] Activation failed: \(error.localizedDescription)")
        }
#endif
        applyLatestContext(from: session)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let payload = WatchGameStatePayload.decode(from: applicationContext) else { return }
        WatchComplicationSharedStore.save(payload)
        WatchComplicationTimelineRefresher.reloadAll()
#if DEBUG
        print(
            "[WatchWidgetConnectivityBootstrap] Context update: " +
            "\(payload.creatureName) \(payload.stage) @ \(payload.currentSteps) steps"
        )
#endif
    }

    private func applyLatestContext(from session: WCSession) {
        let context = session.receivedApplicationContext
        guard !context.isEmpty,
              let payload = WatchGameStatePayload.decode(from: context) else {
            return
        }
        WatchComplicationSharedStore.save(payload)
        WatchComplicationTimelineRefresher.reloadAll()
    }
}
