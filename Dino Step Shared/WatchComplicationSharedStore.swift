//
//  WatchComplicationSharedStore.swift
//  Dino Step Shared
//

import Foundation

/// App Group snapshot used by the watch complication extension and watch app.
enum WatchComplicationSharedStore {
    static let appGroupID = "group.com.gharmon255.dinostep"
    private static let payloadKey = "watchGameStatePayload"

    static func save(_ payload: WatchGameStatePayload) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            log("App Group unavailable: \(appGroupID)")
            return
        }
        guard let data = try? JSONEncoder().encode(payload) else {
            log("Failed to encode watch payload")
            return
        }
        defaults.set(data, forKey: payloadKey)
        log("Saved \(payload.creatureName) \(payload.stage) for complications")
    }

    static func load() -> WatchGameStatePayload? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: payloadKey) else {
            return nil
        }
        return try? JSONDecoder().decode(WatchGameStatePayload.self, from: data)
    }

    private static func log(_ message: String) {
#if DEBUG
        print("[WatchComplicationSharedStore] \(message)")
#endif
    }
}
