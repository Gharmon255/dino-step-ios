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
            stepsUntilNextMilestone: gameState.stepsUntilNextMilestone ?? 0,
            nextStageLabel: nextStageLabel(for: stage),
            isRevealed: isRevealed,
            placeholderVisual: stage == .egg ? "🥚" : stageVisual.displayEmoji,
            updatedAt: Date()
        )
    }

    private static func nextStageLabel(for stage: GrowthStage) -> String {
        switch stage {
        case .egg: "hatch"
        case .baby: "juvenile"
        case .juvenile: "adult"
        case .adult: "complete"
        }
    }
}
#endif
