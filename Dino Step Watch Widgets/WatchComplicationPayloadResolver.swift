//
//  WatchComplicationPayloadResolver.swift
//  Dino Step Watch Widgets
//

import Foundation
import WatchConnectivity

/// Resolves the freshest game-state payload for watch-face complications.
enum WatchComplicationPayloadResolver {
    static func resolve() -> WatchGameStatePayload? {
        WatchWidgetConnectivityBootstrap.shared.prepareSession()

        let cached = WatchComplicationSharedStore.load()
        let fromPhone = payloadFromReceivedApplicationContext()
        let resolved = newest(cached, fromPhone)

        if let resolved {
            WatchComplicationSharedStore.save(resolved)
        }

#if DEBUG
        if let resolved {
            print(
                "[WatchComplicationPayloadResolver] " +
                "\(resolved.creatureName) \(resolved.stage) @ \(resolved.currentSteps) steps"
            )
        } else {
            print("[WatchComplicationPayloadResolver] No payload available")
        }
#endif

        return resolved
    }

    private static func payloadFromReceivedApplicationContext() -> WatchGameStatePayload? {
        guard WCSession.isSupported() else { return nil }

        let context = WCSession.default.receivedApplicationContext
        guard !context.isEmpty else { return nil }
        return WatchGameStatePayload.decode(from: context)
    }

    private static func newest(
        _ cached: WatchGameStatePayload?,
        _ fromPhone: WatchGameStatePayload?
    ) -> WatchGameStatePayload? {
        switch (cached, fromPhone) {
        case (nil, nil):
            return nil
        case (let cached?, nil):
            return cached
        case (nil, let fromPhone?):
            return fromPhone
        case (let cached?, let fromPhone?):
            return fromPhone.updatedAt >= cached.updatedAt ? fromPhone : cached
        }
    }
}
