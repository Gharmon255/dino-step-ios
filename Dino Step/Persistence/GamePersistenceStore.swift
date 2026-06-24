//
//  GamePersistenceStore.swift
//  Dino Step
//

import Foundation

struct GamePersistenceStore {
    private let defaults: UserDefaults
    private let storageKey: String
    private static let backupStorageKey = "dino_step_saved_game_state_backup"

    init(defaults: UserDefaults = .standard, storageKey: String = "dino_step_saved_game_state") {
        self.defaults = defaults
        self.storageKey = storageKey
    }

    func backupRawSaveIfPresent() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        defaults.set(data, forKey: Self.backupStorageKey)
    }

    func loadBackedUpRawSave() -> Data? {
        defaults.data(forKey: Self.backupStorageKey)
    }

    func load() -> PersistenceLoadResult {
        guard let data = defaults.data(forKey: storageKey) else {
            return .noSavedState
        }

        do {
            let savedState = try JSONDecoder().decode(SavedGameState.self, from: data)
            return .success(savedState)
        } catch {
            return .invalidData
        }
    }

    func save(_ state: SavedGameState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: storageKey)
    }

    func replaceSnapshot(_ snapshot: GameStateSnapshot) {
        save(SavedGameStateMapper.makeSavedState(from: snapshot))
    }

    func clear() {
        defaults.removeObject(forKey: storageKey)
    }
}

enum SavedGameStateMapper {
    static func makeSavedState(from gameState: GameStateSnapshot) -> SavedGameState {
        SavedGameState(
            schemaVersion: SavedGameState.currentSchemaVersion,
            activeCreature: SavedActiveCreatureState(
                creatureDefinitionId: gameState.activeCreature.definition.id,
                eggRarity: gameState.activeCreature.eggRarity.rawValue,
                currentSteps: gameState.activeCreature.currentSteps,
                startedAt: gameState.activeCreature.startedAt,
                hatchStep: gameState.activeCreature.progression.hatchStep,
                juvenileStep: gameState.activeCreature.progression.juvenileStep,
                totalStepsRequired: gameState.activeCreature.progression.totalStepsRequired,
                economyVersion: gameState.activeCreature.progression.economyVersion,
                nickname: gameState.activeCreature.nickname
            ),
            completedCreatures: gameState.completedCreatures.map {
                SavedCompletedCreatureState(
                    id: $0.id,
                    creatureDefinitionId: $0.definition.id,
                    totalStepsCompleted: $0.totalStepsCompleted,
                    completedAt: $0.completedAt,
                    nickname: $0.nickname,
                    eggRarityAtHatch: $0.eggRarityAtHatch.rawValue,
                    exSteps: $0.exSteps,
                    exLevel: $0.exLevel
                )
            },
            lastRewardedEggRarity: gameState.lastRewardedEggRarity?.rawValue,
            lastRewardRollPercent: gameState.lastRewardRollPercent,
            lastSyncedHealthKitStepTotal: gameState.lastSyncedHealthKitStepTotal,
            lastHealthKitSyncDayStart: gameState.lastHealthKitSyncDayStart,
            lastHealthKitSyncMessage: gameState.lastHealthKitSyncMessage,
            lifetimeStepsApplied: gameState.lifetimeStepsApplied,
            pendingRewardEggRarity: gameState.pendingRewardEggRarity?.rawValue
        )
    }

    static func restore(from savedState: SavedGameState) -> GameStateSnapshot? {
        guard SavedGameState.isSupportedSchemaVersion(savedState.schemaVersion) else {
            return nil
        }

        guard let activeCreature = restoreActiveCreature(from: savedState.activeCreature) else {
            return nil
        }

        let completedCreatures = savedState.completedCreatures.compactMap(restoreCompletedCreature(from:))

        let lastRewardedEggRarity = savedState.lastRewardedEggRarity.flatMap(Rarity.init(rawValue:))
        if savedState.lastRewardedEggRarity != nil && lastRewardedEggRarity == nil {
            return nil
        }

        return GameStateSnapshot(
            activeCreature: activeCreature,
            completedCreatures: completedCreatures,
            lastRewardedEggRarity: lastRewardedEggRarity,
            lastRewardRollPercent: savedState.lastRewardRollPercent,
            lastSyncedHealthKitStepTotal: savedState.lastSyncedHealthKitStepTotal ?? 0,
            lastHealthKitSyncDayStart: savedState.lastHealthKitSyncDayStart,
            lastHealthKitSyncMessage: savedState.lastHealthKitSyncMessage,
            lifetimeStepsApplied: savedState.lifetimeStepsApplied ?? 0,
            pendingRewardEggRarity: savedState.pendingRewardEggRarity.flatMap(Rarity.init(rawValue:))
        )
    }

    private static func restoreActiveCreature(from saved: SavedActiveCreatureState) -> ActiveCreature? {
        guard saved.currentSteps >= 0,
              let definition = CreatureCatalog.creature(withId: saved.creatureDefinitionId),
              let eggRarity = Rarity(rawValue: saved.eggRarity) else {
            return nil
        }

        let progression: ProgressionThresholds
        if let hatchStep = saved.hatchStep,
           let juvenileStep = saved.juvenileStep,
           let totalStepsRequired = saved.totalStepsRequired,
           let economyVersion = saved.economyVersion {
            progression = ProgressionThresholds(
                hatchStep: hatchStep,
                juvenileStep: juvenileStep,
                totalStepsRequired: totalStepsRequired,
                economyVersion: economyVersion
            )
        } else {
            progression = CreatureEconomy.legacyV1Thresholds(for: definition.speciesId)
        }

        return ActiveCreature(
            eggRarity: eggRarity,
            definition: definition,
            progression: progression,
            currentSteps: saved.currentSteps,
            startedAt: saved.startedAt,
            nickname: saved.nickname
        )
    }

    private static func restoreCompletedCreature(from saved: SavedCompletedCreatureState) -> CompletedCreature? {
        guard saved.totalStepsCompleted >= 0,
              let definition = CreatureCatalog.creature(withId: saved.creatureDefinitionId) else {
            return nil
        }

        return CompletedCreature(
            id: saved.id,
            definition: definition,
            totalStepsCompleted: saved.totalStepsCompleted,
            completedAt: saved.completedAt,
            nickname: saved.nickname,
            eggRarityAtHatch: saved.eggRarityAtHatch.flatMap(Rarity.init(rawValue:)) ?? definition.rarity,
            exSteps: saved.exSteps ?? 0,
            exLevel: max(1, saved.exLevel ?? 1)
        )
    }
}

struct GameStateSnapshot {
    var activeCreature: ActiveCreature
    var completedCreatures: [CompletedCreature]
    var lastRewardedEggRarity: Rarity?
    var lastRewardRollPercent: Double?
    var lastSyncedHealthKitStepTotal: Int
    var lastHealthKitSyncDayStart: Date?
    var lastHealthKitSyncMessage: String?
    var lifetimeStepsApplied: Int
    var pendingRewardEggRarity: Rarity?
}
