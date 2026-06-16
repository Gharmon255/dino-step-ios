//
//  HomeView.swift
//  Dino Step
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var gameState: GameState
    @State private var showTradeConfirmation = false

    private var stage: GrowthStage { gameState.currentStage }
    private var rarityColor: Color { RarityColors.color(for: ambientRarity) }
    private var isHatched: Bool { GameLogic.isHatched(gameState.activeCreature) }

    /// Egg rarity before hatch; creature rarity once revealed (matches Android Home).
    private var ambientRarity: Rarity {
        if isHatched {
            return gameState.activeCreature.definition.rarity
        }
        return gameState.currentEggRarity
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Stepasaurus")
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
                        if stage == .egg {
                            RarityEggView(
                                rarity: gameState.currentEggRarity.rawValue,
                                size: 140,
                                crackLevel: eggCrackLevel
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
                            if stage != .egg {
                                RarityBadge(rarity: gameState.currentEggRarity)
                            }
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
                                label: "Stage Progress",
                                value: stageProgressDisplay
                            )

                            statRow(
                                label: "Overall Progress",
                                value: overallProgressDisplay
                            )
                        }

                        ProgressView(value: stageProgressPercent, total: 100)
                            .tint(rarityColor)
                    }
                    .frame(maxWidth: .infinity)
                }

                HomeCollectionStrip(
                    entries: CollectionCatalog.rosterEntries(from: gameState.completedCreatures),
                    dexDiscovered: gameState.collectionStats.uniqueSpeciesCollected,
                    dexTotal: gameState.collectionStats.totalPossibleSpecies
                )

                VStack(spacing: 12) {
                    if gameState.healthKitAuthorizationStatus == .authorized {
                        Text(
                            HomeSyncStatusText.format(
                                isSyncing: gameState.isSyncingHealthKitSteps,
                                lastSyncDate: gameState.lastHealthKitSyncDate,
                                syncMessage: gameState.lastHealthKitSyncMessage
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                        Button {
                            Task {
                                await gameState.syncHealthKitSteps(manual: true)
                            }
                        } label: {
                            Text(gameState.isSyncingHealthKitSteps ? "Syncing…" : "Sync again")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.borderless)
                        .disabled(gameState.isSyncingHealthKitSteps)
                    } else {
                        Button {
                            Task {
                                await gameState.syncHealthKitSteps(manual: true)
                            }
                        } label: {
                            Group {
                                if gameState.isSyncingHealthKitSteps {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                        Text("Syncing Steps...")
                                    }
                                } else {
                                    Text("Sync Now")
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
                    }

#if DEBUG
                    if !ProcessInfo.processInfo.arguments.contains("-screenshotMode") {
                        HStack(spacing: 12) {
                            stepButton(amount: 500, color: .green)
                            stepButton(amount: 2000, color: .blue)
                        }

                        stepButton(amount: 10000, color: .purple)
                    }
#endif

                    if stage == .adult {
                        Button("Claim Random Egg") {
                            gameState.claimRandomReward()
                        }
                        .buttonStyle(StepButtonStyle(color: RarityColors.color(for: .legendary)))

                        if let tradeOffer = gameState.duplicateTradeOffer {
                            Button(tradeOffer.tradeButtonTitle) {
                                showTradeConfirmation = true
                            }
                            .buttonStyle(StepButtonStyle(color: RarityColors.color(for: tradeOffer.rewardEggRarity)))

                            Text(tradeOffer.helperText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding()
        }
        .confirmationDialog(
            "Trade for tier-up egg?",
            isPresented: $showTradeConfirmation,
            titleVisibility: .visible
        ) {
            Button("Trade", role: .destructive) {
                gameState.tradeDuplicatesForTierUpEgg()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let tradeOffer = gameState.duplicateTradeOffer {
                Text(tradeOffer.confirmationMessage)
            }
        }
        .background {
            RarityScreenBackground(rarity: ambientRarity)
                .animation(.easeInOut(duration: 0.35), value: ambientRarity)
        }
        .alert("Egg hatched!", isPresented: discoveryAlertBinding) {
            Button("Awesome!") {
                gameState.clearPendingDiscovery()
            }
        } message: {
            if let discovery = gameState.pendingDiscovery {
                Text("Meet \(discovery.speciesName)!\n\n\(discovery.funFact)")
            }
        }
    }

    private var discoveryAlertBinding: Binding<Bool> {
        Binding(
            get: { gameState.pendingDiscovery != nil },
            set: { isPresented in
                if !isPresented {
                    gameState.clearPendingDiscovery()
                }
            }
        )
    }

    private var eggCrackLevel: Int {
        guard stage == .egg else { return 0 }
        return EggCrackLevel.forEgg(
            currentSteps: gameState.activeCreature.currentSteps,
            hatchStep: gameState.activeCreature.progression.hatchStep
        )
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

    private var stageProgressPercent: Double {
        GameLogic.stageProgressPercent(
            currentSteps: gameState.activeCreature.currentSteps,
            progression: gameState.activeCreature.progression
        )
    }

    private var stageProgressDisplay: String {
        String(format: "%.1f%%", stageProgressPercent)
    }

    private var overallProgressDisplay: String {
        String(format: "%.1f%% to adult", gameState.progressPercent)
    }

    private var nextStageCopy: String {
        if stage == .adult {
            return "Ready to claim reward"
        }

        let stepsRemaining = max(
            0,
            GameLogic.stepsUntilNextStage(
                currentSteps: gameState.activeCreature.currentSteps,
                progression: gameState.activeCreature.progression
            )
        )

        let label = GameLogic.nextStageLabel(for: stage)
        if stepsRemaining == 0 {
            return "Ready to \(label)"
        }
        return "\(stepsRemaining.formatted()) steps to \(label)"
    }
}

#Preview("Common Egg") {
    HomeView(gameState: GameState())
}

#Preview("Rare Egg") {
    let state = GameState()
    state.giveEgg(rarity: .rare)
    return HomeView(gameState: state)
}

#Preview("Epic Egg") {
    let state = GameState()
    state.giveEgg(rarity: .epic)
    return HomeView(gameState: state)
}

#Preview("Legendary Egg") {
    let state = GameState()
    state.giveEgg(rarity: .legendary)
    return HomeView(gameState: state)
}
