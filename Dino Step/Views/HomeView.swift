//
//  HomeView.swift
//  Dino Step
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var gameState: GameState

    private var stage: GrowthStage { gameState.currentStage }
    private var rarityColor: Color { RarityColors.color(for: gameState.currentEggRarity) }
    private var isHatched: Bool { GameLogic.isHatched(gameState.activeCreature) }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Dino Step")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                GameCard(accentColor: rarityColor) {
                    VStack(spacing: 16) {
                        creaturePlaceholder

                        Text(gameState.displayName)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)

                        HStack(spacing: 8) {
                            RarityBadge(rarity: gameState.currentEggRarity)
                            stageBadge
                        }

                        if isHatched {
                            RarityBadge(rarity: gameState.activeCreature.definition.rarity)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            statRow(label: "Steps", value: "\(gameState.activeCreature.currentSteps.formatted())")

                            if let milestone = gameState.nextMilestone {
                                statRow(label: "Next Milestone", value: "\(milestone.formatted())")
                            }

                            if let remaining = gameState.stepsUntilNextMilestone {
                                statRow(label: "Steps Until Milestone", value: "\(remaining.formatted())")
                            }

                            statRow(
                                label: "Progress",
                                value: String(format: "%.1f%%", gameState.progressPercent)
                            )
                        }

                        ProgressView(value: gameState.progressPercent, total: 100)
                            .tint(rarityColor)
                    }
                    .frame(maxWidth: .infinity)
                }

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        stepButton(amount: 500, color: .green)
                        stepButton(amount: 2000, color: .blue)
                    }

                    stepButton(amount: 10000, color: .purple)

                    if stage == .adult {
                        Button("Claim Reward") {
                            gameState.claimReward()
                        }
                        .buttonStyle(StepButtonStyle(color: RarityColors.color(for: .legendary)))
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private var creaturePlaceholder: some View {
        switch stage {
        case .egg:
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(rarityColor.opacity(0.22))
                    .frame(width: 120, height: 140)
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(rarityColor, lineWidth: 3)
                    .frame(width: 120, height: 140)
                Text("🥚")
                    .font(.system(size: 64))
            }
        case .baby:
            Text("🦖")
                .font(.system(size: 48))
        case .juvenile:
            Text("🦕")
                .font(.system(size: 72))
        case .adult:
            Text("🦕")
                .font(.system(size: 96))
        }
    }

    private var stageBadge: some View {
        Text(stage.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.secondary.opacity(0.15)))
            .foregroundStyle(.secondary)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }

    private func stepButton(amount: Int, color: Color) -> some View {
        Button("+\(amount.formatted())") {
            gameState.addSteps(amount)
        }
        .buttonStyle(StepButtonStyle(color: color))
    }
}

#Preview {
    HomeView(gameState: GameState())
}
