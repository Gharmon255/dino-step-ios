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

    static func stepsUntilNextStage(currentSteps: Int, creatureDefinition: CreatureDefinition) -> Int {
        stepsUntilNextMilestone(currentSteps: currentSteps, creatureDefinition: creatureDefinition) ?? 0
    }

    static func stageProgressPercent(currentSteps: Int, creatureDefinition: CreatureDefinition) -> Double {
        // Progress within the current stage toward the next milestone (not lifetime / fully grown).
        let stage = calculateStage(currentSteps: currentSteps, creatureDefinition: creatureDefinition)

        switch stage {
        case .egg:
            let hatchStep = creatureDefinition.hatchStep
            guard hatchStep > 0 else { return 0 }
            return clampPercent(Double(max(0, currentSteps)) / Double(hatchStep) * 100.0)

        case .baby:
            let start = creatureDefinition.hatchStep
            let end = creatureDefinition.juvenileStep
            let range = end - start
            guard range > 0 else { return 100 }
            return clampPercent(Double(max(0, currentSteps - start)) / Double(range) * 100.0)

        case .juvenile:
            let start = creatureDefinition.juvenileStep
            let end = creatureDefinition.totalStepsRequired
            let range = end - start
            guard range > 0 else { return 100 }
            return clampPercent(Double(max(0, currentSteps - start)) / Double(range) * 100.0)

        case .adult:
            return 100.0
        }
    }

    static func nextStageLabel(for stage: GrowthStage) -> String {
        switch stage {
        case .egg: "hatch"
        case .baby: "juvenile"
        case .juvenile: "adult"
        case .adult: "claim"
        }
    }

    private static func clampPercent(_ value: Double) -> Double {
        min(100.0, max(0.0, value))
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
