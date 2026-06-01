//
//  CreatureStageVisualView.swift
//  Dino Step
//

import SwiftUI

struct CreatureStageVisualView: View {
    let creature: CreatureDefinition
    let stage: GrowthStage
    var eggRarity: Rarity?
    var compact: Bool = false

    private var stageVisual: StageVisual {
        CreatureVisuals.stageVisual(for: creature, stage: stage, eggRarity: eggRarity)
    }

    private var usesCreatureAsset: Bool {
        CreatureAssetVisual.shouldUseAssetImage(forSpeciesId: creature.speciesId, stage: stage.rawValue)
    }

    private var creatureAssetName: String? {
        CreatureAssetVisual.assetName(forSpeciesId: creature.speciesId, stage: stage.rawValue)
    }

    var body: some View {
        if stage == .egg {
            eggView
        } else {
            hatchedView
        }
    }

    @ViewBuilder
    private var eggView: some View {
        let rarity = eggRarity ?? creature.rarity
        RarityEggView(
            rarity: rarity.rawValue,
            size: compact ? 52 : 128,
            compact: compact
        )
    }

    private var hatchedView: some View {
        let visualSize = compact ? 52 : stageVisual.size

        return VStack(spacing: compact ? 0 : 6) {
            ZStack {
                if usesCreatureAsset, let creatureAssetName {
                    Circle()
                        .strokeBorder(stageVisual.accentColor.opacity(0.35), lineWidth: compact ? 2 : 3)
                        .frame(width: visualSize, height: visualSize)

                    Image(creatureAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: visualSize * 0.92, height: visualSize * 0.92)
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [stageVisual.accentColor, stageVisual.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: visualSize, height: visualSize)

                    Circle()
                        .strokeBorder(stageVisual.accentColor.opacity(0.8), lineWidth: compact ? 2 : 3)
                        .frame(width: visualSize, height: visualSize)

                    Text(stageVisual.displayEmoji)
                        .font(.system(size: compact ? 30 : stageVisual.emojiFontSize))
                }
            }

            if !compact {
                Text(stageVisual.stageDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        CreatureStageVisualView(
            creature: CreatureCatalog.commonCreatures[0],
            stage: .baby
        )
        CreatureStageVisualView(
            creature: CreatureCatalog.commonCreatures[0],
            stage: .adult,
            compact: true
        )
    }
    .padding()
}
