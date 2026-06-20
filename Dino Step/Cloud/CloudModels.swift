//
//  CloudModels.swift
//  Dino Step
//

import Foundation

struct CloudGameSave: Codable, Equatable {
    static let schemaVersion = 2

    var schemaVersion: Int
    var revision: Int64
    var updatedAt: String
    var activeCreature: CloudActiveCreature
    var completedCreatures: [CloudCompletedCreature]
    var playerStats: CloudPlayerStats
    var lastRewardedEggRarity: String?
    var lastRewardRollPercent: Double?
}

struct CloudActiveCreature: Codable, Equatable {
    var speciesId: String
    var eggRarity: String
    var steps: Int
    var isRevealed: Bool
    var nickname: String?
    var startedAt: String
    var hatchStep: Int
    var juvenileStep: Int
    var totalStepsRequired: Int
    var economyVersion: Int
}

struct CloudCompletedCreature: Codable, Equatable {
    var id: String
    var speciesId: String
    var stepsCompleted: Int
    var completedAt: String
    var nickname: String?
    var eggRarityAtHatch: String?
    var exSteps: Int?
    var exLevel: Int?
}

struct CloudPlayerStats: Codable, Equatable {
    var eggsHatched: Int
    var creaturesCompleted: Int
    var lastSyncedStepTotal: Int
    var lastSyncDayStartMillis: Int64
    var lifetimeStepsApplied: Int
}

struct CloudSaveRow: Equatable {
    var userId: String
    var schemaVersion: Int
    var revision: Int64
    var save: CloudGameSave
    var updatedAt: String
}

struct CloudSession: Equatable {
    var userId: String
    var accessToken: String
    var refreshToken: String
    var email: String?
    var provider: String?
}

enum CloudSaveConflict: Equatable {
    case localVsCloud(local: CloudGameSave, cloud: CloudGameSave)
}

enum CloudSyncStatus: Equatable {
    case unavailable
    case signedOut
    case syncing
    case backedUp
    case error
}

struct CloudAccountUiState: Equatable {
    var isConfigured: Bool
    var syncStatus: CloudSyncStatus
    var signedInUserId: String?
    var signedInEmail: String?
    var signedInProvider: String?
    var lastBackedUpAtMillis: Int64?
    var lastError: String?
    var pendingConflict: CloudSaveConflict?
}
