//
//  WatchGameStatePayloadBuilder.swift
//  Dino Step
//

import Foundation

#if os(iOS)
enum WatchGameStatePayloadBuilder {
    @MainActor
    static func build(from gameState: GameState) -> WatchGameStatePayload {
        build(from: gameState.snapshot())
    }

    @MainActor
    static func build(from snapshot: GameStateSnapshot) -> WatchGameStatePayload {
        let active = snapshot.activeCreature
        let definition = active.definition
        let stage = GameLogic.calculateStage(
            currentSteps: active.currentSteps,
            creatureDefinition: definition
        )
        let isRevealed = GameLogic.isHatched(active)
        let stageVisual = CreatureVisuals.stageVisual(
            for: definition,
            stage: stage,
            eggRarity: active.eggRarity
        )
        let displayName = GameLogic.displayName(for: active)
        let nextMilestone = GameLogic.nextMilestone(
            currentSteps: active.currentSteps,
            creatureDefinition: definition
        )

        return WatchGameStatePayload(
            displayName: displayName,
            creatureName: definition.name,
            speciesId: definition.speciesId,
            stage: stage.rawValue,
            rarity: active.eggRarity.rawValue,
            currentSteps: active.currentSteps,
            nextMilestone: nextMilestone ?? definition.totalStepsRequired,
            totalStepsRequired: definition.totalStepsRequired,
            progressPercent: GameLogic.progressPercent(
                currentSteps: active.currentSteps,
                creatureDefinition: definition
            ),
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
