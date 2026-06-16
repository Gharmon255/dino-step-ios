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
            progression: active.progression
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
            progression: active.progression
        )

        return WatchGameStatePayload(
            displayName: displayName,
            creatureName: definition.name,
            speciesId: definition.speciesId,
            stage: stage.rawValue,
            rarity: active.eggRarity.rawValue,
            currentSteps: active.currentSteps,
            nextMilestone: nextMilestone ?? active.progression.totalStepsRequired,
            totalStepsRequired: active.progression.totalStepsRequired,
            progressPercent: GameLogic.progressPercent(
                currentSteps: active.currentSteps,
                progression: active.progression
            ),
            stageProgressPercent: GameLogic.stageProgressPercent(
                currentSteps: active.currentSteps,
                progression: active.progression
            ),
            stepsUntilNextStage: GameLogic.stepsUntilNextStage(
                currentSteps: active.currentSteps,
                progression: active.progression
            ),
            nextStageLabel: GameLogic.nextStageLabel(for: stage),
            isRevealed: isRevealed,
            placeholderVisual: stage == .egg ? "🥚" : stageVisual.displayEmoji,
            updatedAt: Date()
        )
    }
}
#endif
