//
//  SavedGameState.swift
//  Dino Step
//

import Foundation

struct SavedGameState: Codable {
    static let currentSchemaVersion = 5

    var schemaVersion: Int
    var activeCreature: SavedActiveCreatureState
    var completedCreatures: [SavedCompletedCreatureState]
    var lastRewardedEggRarity: String?
    var lastRewardRollPercent: Double?
    var lastSyncedHealthKitStepTotal: Int?
    var lastHealthKitSyncDayStart: Date?
    var lastHealthKitSyncMessage: String?
    var lifetimeStepsApplied: Int?
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

    var message: String {
        switch self {
        case .loadedSavedGame: "Loaded saved game"
        case .savedLocally: "Saved locally"
        case .resetAfterInvalidData: "Reset save after invalid data"
        }
    }
}

enum PersistenceLoadResult {
    case noSavedState
    case success(SavedGameState)
    case invalidData
}
