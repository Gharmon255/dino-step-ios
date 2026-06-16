//
//  WatchProgressRingView.swift
//  Dino Step Watch Watch App
//

import SwiftUI

struct WatchProgressRingView: View {
    let progressPercent: Double
    let accentColor: Color
    let placeholderEmoji: String
    var ringSize: CGFloat = 92
    var eggRarity: String?
    var speciesId: String?
    var creatureName: String?
    var stage: String?
    var isEggStage: Bool = false
    var payload: WatchGameStatePayload? = nil

    private var progress: Double {
        min(max(progressPercent / 100.0, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 6)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            centerVisual
        }
        .frame(width: ringSize, height: ringSize)
    }

    @ViewBuilder
    private var centerVisual: some View {
        WatchCreatureCenterVisual(
            payload: payload ?? payloadFromFields,
            visualSize: ringSize * 0.44
        )
    }

    private var payloadFromFields: WatchGameStatePayload? {
        guard let stage, !stage.isEmpty else { return nil }
        return WatchGameStatePayload(
            displayName: creatureName ?? "Creature",
            creatureName: creatureName ?? "Creature",
            speciesId: speciesId,
            stage: stage,
            rarity: eggRarity ?? "COMMON",
            currentSteps: 0,
            nextMilestone: 1,
            totalStepsRequired: 1,
            progressPercent: progressPercent,
            stageProgressPercent: progressPercent,
            stepsUntilNextStage: 0,
            nextStageLabel: "",
            isRevealed: !isEggStage,
            placeholderVisual: placeholderEmoji,
            updatedAt: Date()
        )
    }
}

#Preview {
    WatchProgressRingView(
        progressPercent: 25,
        accentColor: WatchRarityColors.color(for: .common),
        placeholderEmoji: "🦖",
        ringSize: 92,
        speciesId: "tiny_raptor",
        creatureName: "Tiny Raptor",
        stage: "BABY"
    )
}
