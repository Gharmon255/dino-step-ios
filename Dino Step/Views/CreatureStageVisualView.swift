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
    /// When set, overrides compact/default sizing (e.g. Collection card prominence).
    var fixedVisualSize: CGFloat? = nil

    private var stageVisual: StageVisual {
        CreatureVisuals.stageVisual(for: creature, stage: stage, eggRarity: eggRarity)
    }

    private var visualSize: CGFloat {
        fixedVisualSize ?? (compact ? 52 : stageVisual.size)
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
            size: compact ? (fixedVisualSize ?? 52) : 128,
            compact: compact
        )
    }

    private var hatchedView: some View {
        let visualSize = self.visualSize

        return VStack(spacing: compact ? 0 : 6) {
            Group {
                if usesCreatureAsset, let creatureAssetName {
                    Image(creatureAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: visualSize, height: visualSize)
                } else {
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
