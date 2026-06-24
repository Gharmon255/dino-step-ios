//
//  SavedGameState.swift
//  Dino Step
//

import Foundation

struct SavedGameState: Codable {
    static let currentSchemaVersion = 6
    static let minimumSupportedSchemaVersion = 1

    static func isSupportedSchemaVersion(_ version: Int) -> Bool {
        version >= minimumSupportedSchemaVersion && version <= currentSchemaVersion
    }

    var schemaVersion: Int
    var activeCreature: SavedActiveCreatureState
    var completedCreatures: [SavedCompletedCreatureState]
    var lastRewardedEggRarity: String?
    var lastRewardRollPercent: Double?
    var lastSyncedHealthKitStepTotal: Int?
    var lastHealthKitSyncDayStart: Date?
    var lastHealthKitSyncMessage: String?
    var lifetimeStepsApplied: Int?
    var pendingRewardEggRarity: String?
}

struct SavedActiveCreatureState: Codable {
    var creatureDefinitionId: UUID
    var eggRarity: String
    var currentSteps: Int
    var startedAt: Date
    var hatchStep: Int?
    var juvenileStep: Int?
    var totalStepsRequired: Int?
    var economyVersion: Int?
    var nickname: String?
}

struct SavedCompletedCreatureState: Codable {
    var id: UUID
    var creatureDefinitionId: UUID
    var totalStepsCompleted: Int
    var completedAt: Date
    var nickname: String?
    var eggRarityAtHatch: String?
    var exSteps: Int?
    var exLevel: Int?
}

enum PersistenceStatus: Equatable {
    case loadedSavedGame
    case savedLocally
    case resetAfterInvalidData
    case restoredFromCloudBackup

    var message: String {
        switch self {
        case .loadedSavedGame: "Loaded saved game"
        case .savedLocally: "Saved locally"
        case .resetAfterInvalidData: "Reset save after invalid data"
        case .restoredFromCloudBackup: "Restored from cloud backup"
        }
    }
}

enum PersistenceLoadResult {
    case noSavedState
    case success(SavedGameState)
    case invalidData
}
