//
//  HomeSyncStatusText.swift
//  Dino Step
//

import Foundation

enum HomeSyncStatusText {
    static func format(
        isSyncing: Bool,
        lastSyncDate: Date?,
        syncMessage: String?
    ) -> String {
        if isSyncing {
            return "Syncing steps…"
        }
        if let lastSyncDate {
            let elapsed = Date().timeIntervalSince(lastSyncDate)
            if elapsed < 60 {
                return "Synced just now"
            }
            if elapsed < 3_600 {
                let minutes = max(1, Int(elapsed / 60))
                return "Synced \(minutes) min ago"
            }
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return "Synced at \(formatter.string(from: lastSyncDate))"
        }
        return syncMessage ?? "Tap Sync Steps to pull the latest steps from Apple Health"
    }
}
