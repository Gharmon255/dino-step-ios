//
//  CloudSyncPreferences.swift
//  Dino Step
//

import Foundation

final class CloudSyncPreferences {
    private let defaults: UserDefaults
    private let revisionKey = "cloud.localRevision"
    private let backupKey = "cloud.lastBackupAt"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var localRevision: Int64 {
        get { Int64(defaults.integer(forKey: revisionKey)) }
        set { defaults.set(Int(newValue), forKey: revisionKey) }
    }

    var lastBackedUpAtMillis: Int64? {
        get {
            let value = defaults.object(forKey: backupKey) as? Int64
            return value
        }
        set {
            if let newValue {
                defaults.set(newValue, forKey: backupKey)
            } else {
                defaults.removeObject(forKey: backupKey)
            }
        }
    }

    func nextRevision() -> Int64 {
        let next = localRevision + 1
        localRevision = next
        return next
    }
}
