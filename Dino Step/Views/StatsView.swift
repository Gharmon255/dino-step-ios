//
//  StatsView.swift
//  Dino Step
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var gameState: GameState
#if DEBUG && os(iOS)
    @ObservedObject private var watchManager = PhoneWatchConnectivityManager.shared
    @AppStorage(GameState.devNextEggSpeciesOverrideKey) private var devNextEggSpecies: String = "RANDOM"
#elseif os(iOS)
    @ObservedObject private var watchManager = PhoneWatchConnectivityManager.shared
#endif

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

#if os(iOS)
                GameCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Apple Watch Sync")
                            .font(.headline)
                            .foregroundStyle(.indigo)

                        statRow("WC Supported", watchManager.isSupported ? "Yes" : "No")
                        statRow("Session State", watchManager.activationStateLabel)
                        statRow("Watch Paired", watchManager.isPaired ? "Yes" : "No")
                        statRow("Watch App Installed", watchManager.isWatchAppInstalled ? "Yes" : "No")
                        statRow("Watch Reachable", watchManager.isReachable ? "Yes" : "No")
                        statRow("Last Sync Message", watchManager.lastSyncMessage ?? "—")
                        if let syncDate = watchManager.lastSyncDate {
                            statRow("Last Sync Time", syncDate.formatted(date: .omitted, time: .shortened))
                        }

                        if let payload = watchManager.lastSentPayload {
                            Divider()
                            Text("Last Outbound Payload")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            statRow("Species ID", payload.speciesId ?? "— (legacy)")
                            statRow("Display Name", payload.displayName)
                            statRow("Creature Name", payload.creatureName)
                            statRow("Stage", payload.stage)
                            statRow("Rarity", payload.rarity)
                            statRow("Ring Progress", String(format: "%.1f%%", payload.ringProgressPercent))
                            statRow("Stage Progress", String(format: "%.1f%%", payload.stageProgressPercent))
                            statRow("Lifetime Progress", String(format: "%.1f%%", payload.progressPercent))
                            statRow("Steps Until Next", payload.stepsUntilNextStage.formatted())
                        } else {
                            statRow("Last Outbound Payload", "Not sent yet")
                        }
                    }
                }

#if DEBUG && os(iOS)
                GameCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Watch Sync Debug")
                            .font(.headline)
                            .foregroundStyle(.indigo)

                        statRow("Active Species ID", gameState.activeCreature.definition.speciesId)
                        statRow("Active Display Name", gameState.displayName)
                        statRow("Active Stage", gameState.currentStage.rawValue)
                        statRow("Egg Rarity", gameState.currentEggRarity.rawValue)
                        statRow(
                            "Stage Progress (Ring)",
                            String(format: "%.1f%%", GameLogic.stageProgressPercent(
                                currentSteps: gameState.activeCreature.currentSteps,
                                creatureDefinition: gameState.activeCreature.definition
                            ))
                        )
                        statRow(
                            "Lifetime Progress",
                            String(format: "%.1f%%", gameState.progressPercent)
                        )
                        statRow("Watch Reachable", watchManager.isReachable ? "Yes" : "No")
                        if let syncDate = watchManager.lastSyncDate {
                            statRow("Last Sync Time", syncDate.formatted(date: .omitted, time: .shortened))
                        }
                    }
                }
#endif
#endif

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

#if DEBUG && os(iOS)
                GameCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Egg Testing")
                            .font(.headline)
                            .foregroundStyle(.red)

                        Button("Give Random Egg") {
                            gameState.giveRandomEgg()
                        }
                        .buttonStyle(DebugButtonStyle(color: .gray))

                        Text("Give Random Egg by Rarity")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        VStack(spacing: 10) {
                            RarityGiveEggButton(rarity: .common) { gameState.giveEgg(rarity: .common) }
                            RarityGiveEggButton(rarity: .uncommon) { gameState.giveEgg(rarity: .uncommon) }
                            RarityGiveEggButton(rarity: .rare) { gameState.giveEgg(rarity: .rare) }
                            RarityGiveEggButton(rarity: .epic) { gameState.giveEgg(rarity: .epic) }
                            RarityGiveEggButton(rarity: .legendary) { gameState.giveEgg(rarity: .legendary) }
                        }

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

                GameCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Developer Testing")
                            .font(.headline)
                            .foregroundStyle(.pink)

                        Picker("Test Species Override", selection: $devNextEggSpecies) {
                            Text("Random / Normal").tag("RANDOM")
                            Text("Tiny Raptor").tag("tiny_raptor")
                            Text("Triceratops").tag("triceratops")
                            Text("T-Rex").tag("trex")
                            Text("Stegosaurus").tag("stegosaurus")
                            Text("Brachiosaurus").tag("brachiosaurus")
                            Text("Ankylosaurus").tag("ankylosaurus")
                            Text("Parasaurolophus").tag("parasaurolophus")
                            Text("Spinosaurus").tag("spinosaurus")
                            Text("Pteranodon").tag("pteranodon")
                            Text("Dilophosaurus").tag("dilophosaurus")
                            Text("Carnotaurus").tag("carnotaurus")
                            Text("Mosasaurus").tag("mosasaurus")
                            Text("Pachycephalosaurus").tag("pachycephalosaurus")
                            Text("Allosaurus").tag("allosaurus")
                            Text("Iguanodon").tag("iguanodon")
                        }
                        .pickerStyle(.menu)

                        Button("Force Selected Species Egg") {
                            gameState.forceNewEggForTesting()
                        }
                        .buttonStyle(DebugButtonStyle(color: .pink))

                        Text("The species picker only affects Force Selected Species Egg. Rarity buttons and normal gameplay stay random.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Collection check: Force a species → add steps through baby/juvenile/adult → claim reward → open Collection and confirm the adult card shows the correct art (or emoji fallback).")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
#endif
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Stats")
        .onAppear {
            gameState.refreshHealthKitStatus()
#if os(iOS)
            watchManager.activate()
#endif
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
}

#Preview {
    NavigationStack {
        StatsView(gameState: GameState())
    }
}
