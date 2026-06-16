//
//  WatchComplicationEntry.swift
//  Dino Step Watch Widgets
//

import Foundation
import WidgetKit

struct WatchComplicationEntry: TimelineEntry {
    let date: Date
    let payload: WatchGameStatePayload?

    static var preview: WatchComplicationEntry {
        WatchComplicationEntry(
            date: Date(),
            payload: WatchGameStatePayload(
                displayName: "Mystery Egg",
                creatureName: "Tiny Raptor",
                speciesId: "tiny_raptor",
                stage: "EGG",
                rarity: "RARE",
                currentSteps: 8_000,
                nextMilestone: 10_000,
                totalStepsRequired: 100_000,
                progressPercent: 8,
                stageProgressPercent: 80,
                stepsUntilNextStage: 2_000,
                nextStageLabel: "hatch",
                isRevealed: false,
                placeholderVisual: "🥚",
                updatedAt: Date()
            )
        )
    }

    static var current: WatchComplicationEntry {
        WatchComplicationEntry(date: Date(), payload: WatchComplicationPayloadResolver.resolve())
    }

    var accentColorName: String {
        payload?.rarity ?? "COMMON"
    }

    var centerEmoji: String {
        guard let payload else { return "🥚" }
        let trimmed = payload.placeholderVisual.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "🦖" : trimmed
    }

    var progressPercent: Double {
        payload?.ringProgressPercent ?? 0
    }

    var stepsText: String {
        guard let payload else { return "—" }
        return payload.currentSteps.formatted()
    }

    var progressText: String {
        String(format: "%.0f%%", progressPercent)
    }

    var stageText: String {
        payload?.stage ?? "—"
    }

    var milestoneText: String {
        guard let payload else { return "Open iPhone" }
        let compact = payload.milestoneText
        if compact.count <= 10 { return compact }
        return String(compact.prefix(9)) + "…"
    }
}
