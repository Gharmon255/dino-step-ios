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
    var speciesId: String?
    var creatureName: String?
    var stage: String?
    var isEggStage: Bool = false

    private var progress: Double {
        min(max(progressPercent / 100.0, 0), 1)
    }

    private var assetLookupSpeciesId: String? {
        if let speciesId, !speciesId.isEmpty {
            return CreatureAssetVisual.normalizedSpeciesId(from: speciesId) ?? speciesId
        }
        guard let creatureName, !creatureName.isEmpty else { return nil }
        return CreatureAssetVisual.normalizedSpeciesId(from: creatureName)
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
        if isEggStage, let eggRarity, !eggRarity.isEmpty {
            watchEggVisual(for: eggRarity)
        } else if let assetLookupSpeciesId,
                  let stage,
                  !stage.isEmpty,
                  CreatureAssetVisual.shouldUseAssetImage(forSpeciesId: assetLookupSpeciesId, stage: stage),
                  let assetName = CreatureAssetVisual.assetName(forSpeciesId: assetLookupSpeciesId, stage: stage) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
        } else {
            Text(placeholderEmoji.isEmpty ? "🦖" : placeholderEmoji)
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
        speciesId: "tiny_raptor",
        creatureName: "Tiny Raptor",
        stage: "BABY"
    )
}
