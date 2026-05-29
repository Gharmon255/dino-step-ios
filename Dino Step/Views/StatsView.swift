//
//  StatsView.swift
//  Dino Step
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GameCard(accentColor: RarityColors.color(for: gameState.currentEggRarity)) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Run")
                            .font(.headline)
                            .foregroundStyle(RarityColors.color(for: gameState.currentEggRarity))

                        statRow("Active Steps", "\(gameState.activeCreature.currentSteps.formatted())")
                        statRow("Current Egg Rarity", gameState.currentEggRarity.rawValue)
                        statRow(
                            "Creature Rarity (After Hatch)",
                            gameState.revealedCreatureRarity?.rawValue ?? "Hidden"
                        )
                        statRow("Current Stage", gameState.currentStage.rawValue)
                        statRow("Progress", String(format: "%.1f%%", gameState.progressPercent))
                    }
                }

                GameCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lifetime")
                            .font(.headline)
                            .foregroundStyle(.purple)

                        statRow(
                            "Completed Dinosaurs",
                            "\(gameState.completedCreatures.count)"
                        )
                    }
                }

                if let persistenceMessage = gameState.persistenceStatus?.message {
                    GameCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Persistence")
                                .font(.headline)
                                .foregroundStyle(.teal)

                            Text(persistenceMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                GameCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HealthKit")
                            .font(.headline)
                            .foregroundStyle(.teal)

                        statRow("Available", gameState.isHealthKitAvailable ? "Yes" : "No")
                        statRow("Authorized", gameState.healthKitAuthorizationStatus.authorizedDisplay)
                        statRow(
                            "Last Synced Total Today",
                            gameState.lastSyncedHealthKitStepTotal.formatted()
                        )
                        statRow(
                            "Last Sync Message",
                            gameState.lastHealthKitSyncMessage ?? "—"
                        )
                    }
                }

                GameCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Last Reward Roll")
                            .font(.headline)
                            .foregroundStyle(.orange)

                        statRow(
                            "Last Rewarded Egg",
                            gameState.lastRewardedEggRarity?.rawValue ?? "—"
                        )

                        if let roll = gameState.lastRewardRollPercent {
                            statRow("Roll Percent", String(format: "%.2f", roll))
                        }
                    }
                }

                GameCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Testing")
                            .font(.headline)
                            .foregroundStyle(.red)

                        Button("Give Random Egg") {
                            gameState.giveRandomEgg()
                        }
                        .buttonStyle(DebugButtonStyle(color: .gray))

                        rarityGiveButton("Give Common Egg", .common)
                        rarityGiveButton("Give Uncommon Egg", .uncommon)
                        rarityGiveButton("Give Rare Egg", .rare)
                        rarityGiveButton("Give Epic Egg", .epic)
                        rarityGiveButton("Give Legendary Egg", .legendary)

                        Button("Reset Game") {
                            gameState.resetGame()
                        }
                        .buttonStyle(DebugButtonStyle(color: .red))

                        Button("Clear Collection") {
                            gameState.clearCollection()
                        }
                        .buttonStyle(DebugButtonStyle(color: .orange))
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Stats")
        .onAppear {
            gameState.refreshHealthKitStatus()
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func rarityGiveButton(_ title: String, _ rarity: Rarity) -> some View {
        Button(title) {
            gameState.giveEgg(rarity: rarity)
        }
        .buttonStyle(DebugButtonStyle(color: RarityColors.color(for: rarity)))
    }
}

#Preview {
    NavigationStack {
        StatsView(gameState: GameState())
    }
}
