//
//  WatchGameStatePayloadBuilder.swift
//  Dino Step
//

import Foundation

#if os(iOS)
enum WatchGameStatePayloadBuilder {
    @MainActor
    static func build(from gameState: GameState) -> WatchGameStatePayload {
        let active = gameState.activeCreature
        let definition = active.definition
        let stage = gameState.currentStage
        let isRevealed = GameLogic.isHatched(active)
        let stageVisual = CreatureVisuals.stageVisual(
            for: definition,
            stage: stage,
            eggRarity: active.eggRarity
        )

        return WatchGameStatePayload(
            displayName: gameState.displayName,
            creatureName: definition.name,
            stage: stage.rawValue,
            rarity: active.eggRarity.rawValue,
            currentSteps: active.currentSteps,
            nextMilestone: gameState.nextMilestone ?? definition.totalStepsRequired,
            totalStepsRequired: definition.totalStepsRequired,
            progressPercent: gameState.progressPercent,
            stageProgressPercent: GameLogic.stageProgressPercent(
                currentSteps: active.currentSteps,
                creatureDefinition: definition
            ),
            stepsUntilNextStage: GameLogic.stepsUntilNextStage(
                currentSteps: active.currentSteps,
                creatureDefinition: definition
            ),
            nextStageLabel: GameLogic.nextStageLabel(for: stage),
            isRevealed: isRevealed,
            placeholderVisual: stage == .egg ? "🥚" : stageVisual.displayEmoji,
            updatedAt: Date()
        )
    }
}
#endif
