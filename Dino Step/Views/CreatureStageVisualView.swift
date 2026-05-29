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

    private var eggView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(stageVisual.accentColor.opacity(0.22))
                .frame(width: stageVisual.size, height: stageVisual.size * 1.15)
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(stageVisual.accentColor, lineWidth: 3)
                .frame(width: stageVisual.size, height: stageVisual.size * 1.15)
            Text(stageVisual.displayEmoji)
                .font(.system(size: compact ? 40 : stageVisual.emojiFontSize))
        }
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
            stage: .baby
        )
        CreatureStageVisualView(
            creature: CreatureCatalog.uncommonCreatures.first { $0.name == "Carnotaurus" }!,
            stage: .juvenile
        )
        CreatureStageVisualView(
            creature: CreatureCatalog.uncommonCreatures.first { $0.name == "Carnotaurus" }!,
            stage: .adult
        )
    }
    .padding()
}
