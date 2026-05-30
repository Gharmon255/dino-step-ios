//
//  WatchProgressRingView.swift
//  Dino Step Watch Watch App
//

import SwiftUI

struct WatchProgressRingView: View {
    let progressPercent: Double
    let accentColor: Color
    let placeholderEmoji: String
    var eggRarity: String?
    var creatureName: String?
    var stage: String?
    var isEggStage: Bool = false

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

            Text(String(format: "%.0f%%", progressPercent))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .offset(y: 34)
        }
        .frame(width: 96, height: 96)
    }

    @ViewBuilder
    private var centerVisual: some View {
        if isEggStage, let eggRarity {
            watchEggVisual(for: eggRarity)
        } else if let creatureName, let stage,
                  CreatureAssetVisual.shouldUseAssetImage(for: creatureName, stage: stage),
                  let assetName = CreatureAssetVisual.assetName(for: creatureName, stage: stage) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
        } else {
            Text(placeholderEmoji)
                .font(.system(size: 28))
        }
    }

    @ViewBuilder
    private func watchEggVisual(for rarity: String) -> some View {
        if RarityEggVisual.shouldUseAssetImage(for: rarity) {
            Image(RarityEggVisual.assetName(for: rarity))
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
        } else {
            RarityEggView(rarity: rarity, size: 32, compact: true)
        }
    }
}

#Preview {
    WatchProgressRingView(
        progressPercent: 25,
        accentColor: WatchRarityColors.color(for: .common),
        placeholderEmoji: "🦖",
        creatureName: "Tiny Raptor",
        stage: "BABY"
    )
}
