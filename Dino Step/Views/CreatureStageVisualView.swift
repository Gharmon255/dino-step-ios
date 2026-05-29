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
        let circleSize = compact ? 52 : stageVisual.size
        let emojiSize = compact ? 30 : stageVisual.emojiFontSize

        return VStack(spacing: compact ? 0 : 6) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [stageVisual.accentColor, stageVisual.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: circleSize, height: circleSize)

                Circle()
                    .strokeBorder(stageVisual.accentColor.opacity(0.8), lineWidth: compact ? 2 : 3)
                    .frame(width: circleSize, height: circleSize)

                Text(stageVisual.displayEmoji)
                    .font(.system(size: emojiSize))
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
            stage: .egg,
            eggRarity: .legendary
        )
        CreatureStageVisualView(
            creature: CreatureCatalog.commonCreatures[0],
            stage: .baby
        )
    }
    .padding()
}
