//
//  GameState.swift
//  Dino Step
//

import Combine
import Foundation

@MainActor
final class GameState: ObservableObject {
    @Published private(set) var activeCreature: ActiveCreature
    @Published private(set) var completedCreatures: [CompletedCreature] = []
    @Published private(set) var lastRewardedEggRarity: Rarity?
    @Published private(set) var lastRewardRollPercent: Double?
    @Published private(set) var persistenceStatus: PersistenceStatus?

    private let persistenceStore: GamePersistenceStore

    init(persistenceStore: GamePersistenceStore? = nil) {
        let store = persistenceStore ?? GamePersistenceStore()
        self.persistenceStore = store

        switch store.load() {
        case .noSavedState:
            activeCreature = Self.makeMysteryEgg(rarity: .common)
        case .success(let savedState):
            if let snapshot = SavedGameStateMapper.restore(from: savedState) {
                activeCreature = snapshot.activeCreature
                completedCreatures = snapshot.completedCreatures
                lastRewardedEggRarity = snapshot.lastRewardedEggRarity
                lastRewardRollPercent = snapshot.lastRewardRollPercent
                persistenceStatus = .loadedSavedGame
            } else {
                activeCreature = Self.makeMysteryEgg(rarity: .common)
                persistenceStatus = .resetAfterInvalidData
                persistCurrentState()
            }
        case .invalidData:
            activeCreature = Self.makeMysteryEgg(rarity: .common)
            persistenceStatus = .resetAfterInvalidData
            persistCurrentState()
        }
    }

    var currentEggRarity: Rarity {
        activeCreature.eggRarity
    }

    var currentStage: GrowthStage {
        GameLogic.calculateStage(
            currentSteps: activeCreature.currentSteps,
            creatureDefinition: activeCreature.definition
        )
    }

    var displayName: String {
        GameLogic.displayName(for: activeCreature)
    }

    var progressPercent: Double {
        GameLogic.progressPercent(
            currentSteps: activeCreature.currentSteps,
            creatureDefinition: activeCreature.definition
        )
    }

    var nextMilestone: Int? {
        GameLogic.nextMilestone(
            currentSteps: activeCreature.currentSteps,
            creatureDefinition: activeCreature.definition
        )
    }

    var stepsUntilNextMilestone: Int? {
        GameLogic.stepsUntilNextMilestone(
            currentSteps: activeCreature.currentSteps,
            creatureDefinition: activeCreature.definition
        )
    }

    var revealedCreatureRarity: Rarity? {
        GameLogic.isHatched(activeCreature) ? activeCreature.definition.rarity : nil
    }

    func addSteps(_ amount: Int) {
        guard amount > 0 else { return }
        activeCreature.currentSteps += amount
        persistCurrentState()
    }

    func claimReward() {
        guard currentStage == .adult else { return }

        let completed = CompletedCreature(
            id: UUID(),
            definition: activeCreature.definition,
            totalStepsCompleted: activeCreature.definition.totalStepsRequired,
            completedAt: Date()
        )
        completedCreatures.append(completed)

        let outcome = EggRewardLogic.rollEggReward()
        lastRewardedEggRarity = outcome.rarity
        lastRewardRollPercent = outcome.rollPercent
        activeCreature = Self.makeMysteryEgg(rarity: outcome.rarity)
        persistCurrentState()
    }

    func giveRandomEgg() {
        let outcome = EggRewardLogic.rollEggReward()
        lastRewardedEggRarity = outcome.rarity
        lastRewardRollPercent = outcome.rollPercent
        activeCreature = Self.makeMysteryEgg(rarity: outcome.rarity)
        persistCurrentState()
    }

    func giveEgg(rarity: Rarity) {
        lastRewardedEggRarity = rarity
        lastRewardRollPercent = nil
        activeCreature = Self.makeMysteryEgg(rarity: rarity)
        persistCurrentState()
    }

    func resetGame() {
        completedCreatures = []
        lastRewardedEggRarity = nil
        lastRewardRollPercent = nil
        activeCreature = Self.makeMysteryEgg(rarity: .common)
        persistCurrentState()
    }

    func clearCollection() {
        completedCreatures = []
        persistCurrentState()
    }

    static func makeMysteryEgg(rarity: Rarity) -> ActiveCreature {
        let definition = CreatureCatalog.creatures(for: rarity).randomElement()!
        return ActiveCreature(
            eggRarity: rarity,
            definition: definition,
            currentSteps: 0,
            startedAt: Date()
        )
    }

    private func persistCurrentState() {
        let snapshot = GameStateSnapshot(
            activeCreature: activeCreature,
            completedCreatures: completedCreatures,
            lastRewardedEggRarity: lastRewardedEggRarity,
            lastRewardRollPercent: lastRewardRollPercent
        )
        persistenceStore.save(SavedGameStateMapper.makeSavedState(from: snapshot))
        persistenceStatus = .savedLocally
    }
}
