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

                ZStack {
                    if stage == .egg {
                        let glow = RarityColors.eggStyle(for: gameState.currentEggRarity)
                        if glow.showsGlow {
                            Circle()
                                .fill(glow.glow.opacity(RarityColors.cardGlowOpacity(for: gameState.currentEggRarity) + 0.12))
                                .frame(width: 180, height: 180)
                                .blur(radius: 24)
                        }
                    }

                    GameCard(accentColor: rarityColor) {
                    VStack(spacing: 16) {
                        if stage == .egg {
                            RarityEggView(
                                rarity: gameState.currentEggRarity.rawValue,
                                size: 140
                            )
                            .padding(.top, 4)
                        } else {
                            CreatureStageVisualView(
                                creature: gameState.activeCreature.definition,
                                stage: stage,
                                eggRarity: gameState.currentEggRarity
                            )
                        }

                        Text(gameState.displayName)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .foregroundStyle(stage == .egg ? rarityColor : .primary)

                        HStack(spacing: 8) {
                            RarityBadge(rarity: gameState.currentEggRarity)
                            stageBadge
                        }

                        if isHatched {
                            RarityBadge(rarity: gameState.activeCreature.definition.rarity)
                        }

                        if stage == .egg {
                            Text("Walk steps to hatch this mystery egg")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            statRow(label: "Steps", value: "\(gameState.activeCreature.currentSteps.formatted())")

                            statRow(label: "Next", value: nextStageCopy)

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
                }

                VStack(spacing: 12) {
                    Button {
                        Task {
                            await gameState.syncHealthKitSteps()
                        }
                    } label: {
                        Group {
                            if gameState.isSyncingHealthKitSteps {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("Syncing Steps...")
                                }
                            } else {
                                Text("Sync Steps")
                            }
                        }
                    }
                    .buttonStyle(StepButtonStyle(color: .teal))
                    .disabled(gameState.isSyncingHealthKitSteps)

                    if let syncMessage = gameState.lastHealthKitSyncMessage {
                        Text(syncMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }

#if DEBUG
                    HStack(spacing: 12) {
                        stepButton(amount: 500, color: .green)
                        stepButton(amount: 2000, color: .blue)
                    }

                    stepButton(amount: 10000, color: .purple)
#endif

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

    private var nextStageCopy: String {
        if stage == .adult {
            return "Ready to claim reward"
        }

        let stepsRemaining = max(
            0,
            GameLogic.stepsUntilNextStage(
                currentSteps: gameState.activeCreature.currentSteps,
                creatureDefinition: gameState.activeCreature.definition
            )
        )

        let label = GameLogic.nextStageLabel(for: stage)
        if stepsRemaining == 0 {
            return "Ready to \(label)"
        }
        return "\(stepsRemaining.formatted()) steps to \(label)"
    }
}

#Preview {
    HomeView(gameState: GameState())
}
