//
//  GameLogic.swift
//  Dino Step
//

import Foundation

enum GameLogic {
    static func calculateStage(currentSteps: Int, progression: ProgressionThresholds) -> GrowthStage {
        progression.stage(for: currentSteps)
    }

    static func calculateStage(currentSteps: Int, creatureDefinition: CreatureDefinition) -> GrowthStage {
        calculateStage(
            currentSteps: currentSteps,
            progression: CreatureEconomy.catalogThresholds(for: creatureDefinition.rarity)
        )
    }

    static func nextMilestone(currentSteps: Int, progression: ProgressionThresholds) -> Int? {
        progression.nextMilestone(for: currentSteps)
    }

    static func nextMilestone(currentSteps: Int, creatureDefinition: CreatureDefinition) -> Int? {
        nextMilestone(
            currentSteps: currentSteps,
            progression: CreatureEconomy.catalogThresholds(for: creatureDefinition.rarity)
        )
    }

    static func progressPercent(currentSteps: Int, progression: ProgressionThresholds) -> Double {
        progression.overallProgressPercent(for: currentSteps)
    }

    static func progressPercent(currentSteps: Int, creatureDefinition: CreatureDefinition) -> Double {
        progressPercent(
            currentSteps: currentSteps,
            progression: CreatureEconomy.catalogThresholds(for: creatureDefinition.rarity)
        )
    }

    static func stepsUntilNextMilestone(currentSteps: Int, progression: ProgressionThresholds) -> Int? {
        guard let milestone = nextMilestone(currentSteps: currentSteps, progression: progression) else {
            return nil
        }
        return max(0, milestone - currentSteps)
    }

    static func stepsUntilNextMilestone(currentSteps: Int, creatureDefinition: CreatureDefinition) -> Int? {
        stepsUntilNextMilestone(
            currentSteps: currentSteps,
            progression: CreatureEconomy.catalogThresholds(for: creatureDefinition.rarity)
        )
    }

    static func stepsUntilNextStage(currentSteps: Int, progression: ProgressionThresholds) -> Int {
        stepsUntilNextMilestone(currentSteps: currentSteps, progression: progression) ?? 0
    }

    static func stepsUntilNextStage(currentSteps: Int, creatureDefinition: CreatureDefinition) -> Int {
        stepsUntilNextStage(
            currentSteps: currentSteps,
            progression: CreatureEconomy.catalogThresholds(for: creatureDefinition.rarity)
        )
    }

    static func stageProgressPercent(currentSteps: Int, progression: ProgressionThresholds) -> Double {
        progression.stageProgressPercent(for: currentSteps)
    }

    static func stageProgressPercent(currentSteps: Int, creatureDefinition: CreatureDefinition) -> Double {
        stageProgressPercent(
            currentSteps: currentSteps,
            progression: CreatureEconomy.catalogThresholds(for: creatureDefinition.rarity)
        )
    }

    static func nextStageLabel(for stage: GrowthStage) -> String {
        switch stage {
        case .egg: "hatch"
        case .baby: "juvenile"
        case .juvenile: "adult"
        case .adult: "claim"
        }
    }

    static func displayName(for activeCreature: ActiveCreature) -> String {
        if calculateStage(currentSteps: activeCreature.currentSteps, progression: activeCreature.progression) == .egg {
            return activeCreature.eggRarity.mysteryEggTitle
        }
        return activeCreature.definition.name
    }

    static func isHatched(_ activeCreature: ActiveCreature) -> Bool {
        calculateStage(currentSteps: activeCreature.currentSteps, progression: activeCreature.progression) != .egg
    }
}
