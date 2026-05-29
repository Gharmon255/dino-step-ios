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

    init() {
        activeCreature = Self.makeMysteryEgg(rarity: .common)
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
    }

    func giveRandomEgg() {
        let outcome = EggRewardLogic.rollEggReward()
        lastRewardedEggRarity = outcome.rarity
        lastRewardRollPercent = outcome.rollPercent
        activeCreature = Self.makeMysteryEgg(rarity: outcome.rarity)
    }

    func giveEgg(rarity: Rarity) {
        lastRewardedEggRarity = rarity
        lastRewardRollPercent = nil
        activeCreature = Self.makeMysteryEgg(rarity: rarity)
    }

    func resetGame() {
        completedCreatures = []
        lastRewardedEggRarity = nil
        lastRewardRollPercent = nil
        activeCreature = Self.makeMysteryEgg(rarity: .common)
    }

    func clearCollection() {
        completedCreatures = []
    }

    static func makeMysteryEgg(rarity: Rarity) -> ActiveCreature {
        let definition = CreatureCatalog.creatures(for: rarity).randomElement()!
        return ActiveCreature(eggRarity: rarity, definition: definition, currentSteps: 0)
    }
}
