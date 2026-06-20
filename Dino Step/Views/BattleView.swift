//
//  BattleView.swift
//  Dino Step
//

import SwiftUI

struct BattleView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject private var cloudSyncEngine: CloudSaveSyncEngine
    @State private var inviteCodeInput = ""

    init(gameState: GameState) {
        self.gameState = gameState
        self._cloudSyncEngine = ObservedObject(wrappedValue: gameState.cloudSyncEngine)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if !SupabaseConfig.shared.isConfigured {
                    Text("Cloud backup is not configured on this build.")
                } else if cloudSyncEngine.uiState.syncStatus == .signedOut {
                    Text("Sign in from Stats to battle other players.")
                } else {
                    if let code = gameState.battleInviteCode {
                        Text("Battle code: \(code)")
                            .font(.headline)
                        Text("Share this 5-letter code with your opponent (new code each Challenge).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if gameState.isBattleLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }

                    if let message = gameState.battleStatusMessage {
                        Text(message)
                            .foregroundStyle(.green)
                    }

                    Text("Choose your fighter")
                        .font(.headline)

                    if gameState.completedCreatures.isEmpty {
                        Text("Claim an adult dinosaur to unlock battles.")
                    } else {
                        ForEach(gameState.completedCreatures) { fighter in
                            FighterPickRow(
                                fighter: fighter,
                                collection: gameState.completedCreatures,
                                selected: gameState.selectedBattleFighter?.id == fighter.id
                            ) {
                                gameState.selectBattleFighter(fighter)
                            }
                        }
                    }

                    HStack {
                        Button("Quick match") {
                            gameState.findQuickMatch()
                        }
                        .disabled(gameState.selectedBattleFighter == nil || gameState.isBattleLoading)

                        Button("Challenge") {
                            gameState.createFriendChallenge()
                        }
                        .disabled(gameState.isBattleLoading)
                    }

                    TextField("Opponent's 5-letter battle code", text: $inviteCodeInput)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .onChange(of: inviteCodeInput) { _, newValue in
                            let filtered = newValue.uppercased().filter { $0.isLetter || $0.isNumber }
                            inviteCodeInput = String(filtered.prefix(5))
                        }

                    Button("Accept & blind pick") {
                        gameState.acceptFriendChallenge(inviteCode: inviteCodeInput)
                    }
                    .disabled(
                        inviteCodeInput.count != 5 ||
                            gameState.selectedBattleFighter == nil ||
                            gameState.isBattleLoading
                    )

                    if let challengeId = gameState.activeBattleChallengeId {
                        Button("Lock in fighter (hidden until reveal)") {
                            gameState.submitBattlePick(challengeId: challengeId)
                        }
                        .disabled(gameState.selectedBattleFighter == nil || gameState.isBattleLoading)
                    }

                    if let battle = gameState.latestBattle {
                        BattleResultCard(
                            battle: battle,
                            headline: gameState.battleOutcomeHeadline(for: battle)
                        )
                    }

                    if !gameState.battleHistory.isEmpty {
                        Text("Recent battles")
                            .font(.headline)
                        ForEach(gameState.battleHistory.prefix(5)) { battle in
                            Text("\(displayName(battle.playerASpeciesId)) vs \(displayName(battle.playerBSpeciesId)) — \(gameState.battleOutcomeHeadline(for: battle))")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Battle")
        .onAppear {
            gameState.resumeBattlePollingIfNeeded()
        }
    }

    private func displayName(_ speciesId: String) -> String {
        CreatureCatalog.creature(withSpeciesId: speciesId)?.name ?? speciesId
    }
}

private struct FighterPickRow: View {
    let fighter: CompletedCreature
    let collection: [CompletedCreature]
    let selected: Bool
    let onSelect: () -> Void

    var body: some View {
        let power = BattlePowerCalculator.compute(fighter: fighter, collection: collection)
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                Text(fighter.displayName)
                    .font(.headline)
                Text("Power \(power.combatPower) · EX \(power.exLevel) · Pack ×\(power.packCount)")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(selected ? Color.green.opacity(0.2) : Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

private struct BattleResultCard: View {
    let battle: BattleRecord
    let headline: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(headline)
                .font(.headline)
            Text("\(displayName(battle.playerASpeciesId)) (\(battle.playerAPower)) vs \(displayName(battle.playerBSpeciesId)) (\(battle.playerBPower))")
                .font(.subheadline)
            ForEach(battle.turnLog) { turn in
                Text(turn.message.isEmpty ? "Turn \(turn.turn): \(turn.action) -\(turn.damage)" : turn.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func displayName(_ speciesId: String) -> String {
        CreatureCatalog.creature(withSpeciesId: speciesId)?.name ?? speciesId
    }
}
