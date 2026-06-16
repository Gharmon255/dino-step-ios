//
//  GamePersistenceStore.swift
//  Dino Step
//

import Foundation

struct GamePersistenceStore {
    private let defaults: UserDefaults
    private let storageKey: String

    init(defaults: UserDefaults = .standard, storageKey: String = "dino_step_saved_game_state") {
        self.defaults = defaults
        self.storageKey = storageKey
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
                startedAt: gameState.activeCreature.startedAt
            ),
            completedCreatures: gameState.completedCreatures.map {
                SavedCompletedCreatureState(
                    id: $0.id,
                    creatureDefinitionId: $0.definition.id,
                    totalStepsCompleted: $0.totalStepsCompleted,
                    completedAt: $0.completedAt
                )
            },
            lastRewardedEggRarity: gameState.lastRewardedEggRarity?.rawValue,
            lastRewardRollPercent: gameState.lastRewardRollPercent,
            lastSyncedHealthKitStepTotal: gameState.lastSyncedHealthKitStepTotal,
            lastHealthKitSyncDayStart: gameState.lastHealthKitSyncDayStart,
            lastHealthKitSyncMessage: gameState.lastHealthKitSyncMessage,
            lifetimeStepsApplied: gameState.lifetimeStepsApplied
        )
    }

    static func restore(from savedState: SavedGameState) -> GameStateSnapshot? {
        guard savedState.schemaVersion == 1 || savedState.schemaVersion == SavedGameState.currentSchemaVersion else {
            return nil
        }

        guard let activeCreature = restoreActiveCreature(from: savedState.activeCreature) else {
            return nil
        }

        var completedCreatures: [CompletedCreature] = []
        for savedCreature in savedState.completedCreatures {
            guard let completed = restoreCompletedCreature(from: savedCreature) else {
                return nil
            }
            completedCreatures.append(completed)
        }

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
            lifetimeStepsApplied: savedState.lifetimeStepsApplied ?? 0
        )
    }

    private static func restoreActiveCreature(from saved: SavedActiveCreatureState) -> ActiveCreature? {
        guard saved.currentSteps >= 0,
              let definition = CreatureCatalog.creature(withId: saved.creatureDefinitionId),
              let eggRarity = Rarity(rawValue: saved.eggRarity) else {
            return nil
        }

        return ActiveCreature(
            eggRarity: eggRarity,
            definition: definition,
            currentSteps: saved.currentSteps,
            startedAt: saved.startedAt
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
            completedAt: saved.completedAt
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
}
