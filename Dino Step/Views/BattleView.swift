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
        ZStack {
            BattleArenaBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !SupabaseConfig.shared.isConfigured {
                        BattleSignInPrompt()
                    } else if cloudSyncEngine.uiState.syncStatus == .signedOut {
                        BattleSignInPrompt()
                    } else {
                        signedInContent
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Battle Arena")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .onAppear {
            gameState.resumeBattlePollingIfNeeded()
        }
    }

    @ViewBuilder
    private var signedInContent: some View {
        if let battle = gameState.latestBattle {
            BattleRevealCard(
                battle: battle,
                headline: gameState.battleOutcomeHeadline(for: battle),
                currentUserId: cloudSyncEngine.uiState.signedInUserId
            )
        }

        if gameState.isBattleLoading {
            HStack {
                Spacer()
                ProgressView()
                    .tint(.white)
                Spacer()
            }
            .padding(.vertical, 8)
        }

        if let message = gameState.battleStatusMessage {
            BattleStatusBanner(message: message)
        }

        if let code = gameState.battleInviteCode {
            BattleCodeBanner(code: code)
        }

        actionSection
        joinSection

        if let challengeId = gameState.activeBattleChallengeId {
            BattleActionButton(
                title: "Lock in fighter",
                systemImage: "lock.shield.fill",
                style: .accent,
                disabled: gameState.selectedBattleFighter == nil || gameState.isBattleLoading
            ) {
                gameState.submitBattlePick(challengeId: challengeId)
            }
        }

        fighterSection

        if !gameState.battleHistory.isEmpty {
            historySection
        }
    }

    private var fighterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            BattleSectionHeader(
                title: "Choose your champion",
                subtitle: "Adults only · picks stay hidden in friend battles"
            )

            if gameState.completedCreatures.isEmpty {
                GameCard {
                    VStack(spacing: 10) {
                        Image(systemName: "tortoise.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Hatch and claim an adult dinosaur to unlock battles.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(sortedFighters) { fighter in
                        BattleFighterCard(
                            fighter: fighter,
                            collection: gameState.completedCreatures,
                            selected: gameState.selectedBattleFighter?.id == fighter.id
                        ) {
                            gameState.selectBattleFighter(fighter)
                        }
                    }
                }
            }
        }
    }

    private var actionSection: some View {
        VStack(spacing: 10) {
            BattleSectionHeader(title: "Battle modes")

            HStack(spacing: 10) {
                BattleActionButton(
                    title: "Quick match",
                    systemImage: "bolt.circle.fill",
                    style: .primary,
                    disabled: gameState.selectedBattleFighter == nil || gameState.isBattleLoading
                ) {
                    gameState.findQuickMatch()
                }

                BattleActionButton(
                    title: "Challenge",
                    systemImage: "flag.checkered",
                    style: .secondary,
                    disabled: gameState.isBattleLoading
                ) {
                    gameState.createFriendChallenge()
                }
            }
        }
    }

    private var joinSection: some View {
        VStack(spacing: 12) {
            BattleSectionHeader(
                title: "Join a friend",
                subtitle: "Enter the host's 5-letter code"
            )

            BattleJoinCodeField(code: $inviteCodeInput)

            BattleActionButton(
                title: "Accept & blind pick",
                systemImage: "eye.slash.fill",
                style: .accent,
                disabled: inviteCodeInput.count != 5 ||
                    gameState.selectedBattleFighter == nil ||
                    gameState.isBattleLoading
            ) {
                gameState.acceptFriendChallenge(inviteCode: inviteCodeInput)
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BattleSectionHeader(title: "Recent battles")

            ForEach(gameState.battleHistory.prefix(5)) { battle in
                BattleHistoryRow(
                    battle: battle,
                    headline: gameState.battleOutcomeHeadline(for: battle)
                )
            }
        }
    }

    private var sortedFighters: [CompletedCreature] {
        gameState.completedCreatures.sorted { lhs, rhs in
            let lp = BattlePowerCalculator.compute(fighter: lhs, collection: gameState.completedCreatures).combatPower
            let rp = BattlePowerCalculator.compute(fighter: rhs, collection: gameState.completedCreatures).combatPower
            return lp > rp
        }
    }
}

#Preview {
    NavigationStack {
        BattleView(gameState: GameState())
    }
}
