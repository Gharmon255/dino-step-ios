//
//  SavedGameState.swift
//  Dino Step
//

import Foundation

struct SavedGameState: Codable {
    static let currentSchemaVersion = 2

    var schemaVersion: Int
    var activeCreature: SavedActiveCreatureState
    var completedCreatures: [SavedCompletedCreatureState]
    var lastRewardedEggRarity: String?
    var lastRewardRollPercent: Double?
    var lastSyncedHealthKitStepTotal: Int?
    var lastHealthKitSyncDayStart: Date?
    var lastHealthKitSyncMessage: String?
}

struct SavedActiveCreatureState: Codable {
    var creatureDefinitionId: UUID
    var eggRarity: String
    var currentSteps: Int
    var startedAt: Date
}

struct SavedCompletedCreatureState: Codable {
    var id: UUID
    var creatureDefinitionId: UUID
    var totalStepsCompleted: Int
    var completedAt: Date
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
