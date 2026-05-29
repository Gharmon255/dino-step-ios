//
//  GameLogic.swift
//  Dino Step
//

import Foundation

enum GameLogic {
    static func calculateStage(currentSteps: Int, creatureDefinition: CreatureDefinition) -> GrowthStage {
        if currentSteps >= creatureDefinition.totalStepsRequired {
            return .adult
        } else if currentSteps >= creatureDefinition.juvenileStep {
            return .juvenile
        } else if currentSteps >= creatureDefinition.hatchStep {
            return .baby
        } else {
            return .egg
        }
    }

    static func nextMilestone(currentSteps: Int, creatureDefinition: CreatureDefinition) -> Int? {
        switch calculateStage(currentSteps: currentSteps, creatureDefinition: creatureDefinition) {
        case .egg:
            return creatureDefinition.hatchStep
        case .baby:
            return creatureDefinition.juvenileStep
        case .juvenile:
            return creatureDefinition.totalStepsRequired
        case .adult:
            return nil
        }
    }

    static func progressPercent(currentSteps: Int, creatureDefinition: CreatureDefinition) -> Double {
        min(100.0, Double(currentSteps) / Double(creatureDefinition.totalStepsRequired) * 100.0)
    }

    static func stepsUntilNextMilestone(currentSteps: Int, creatureDefinition: CreatureDefinition) -> Int? {
        guard let milestone = nextMilestone(currentSteps: currentSteps, creatureDefinition: creatureDefinition) else {
            return nil
        }
        return max(0, milestone - currentSteps)
    }

    static func displayName(for activeCreature: ActiveCreature) -> String {
        if calculateStage(
            currentSteps: activeCreature.currentSteps,
            creatureDefinition: activeCreature.definition
        ) == .egg {
            return activeCreature.eggRarity.mysteryEggTitle
        }
        return activeCreature.definition.name
    }

    static func isHatched(_ activeCreature: ActiveCreature) -> Bool {
        calculateStage(
            currentSteps: activeCreature.currentSteps,
            creatureDefinition: activeCreature.definition
        ) != .egg
    }
}
