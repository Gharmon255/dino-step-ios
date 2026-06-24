//
//  PromoCodeCard.swift
//  Dino Step
//

import SwiftUI

struct PromoCodeCard: View {
    @ObservedObject var gameState: GameState
    let isSignedIn: Bool

    @State private var codeInput = ""

    var body: some View {
        if !isSignedIn {
            EmptyView()
        } else {
            GameCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Promo code")
                        .font(.headline)

                    if gameState.hasPendingEpicRewardEgg {
                        Text("Epic egg queued! Claim your next adult to hatch it.")
                            .font(.subheadline)
                            .foregroundStyle(.teal)
                    } else if gameState.epic20PromoRedeemed {
                        Text("Code EPIC20 already used on this account.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Enter a one-time code while signed in. Your next reward egg uses the promo rarity.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("Promo code", text: $codeInput)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                            .disabled(gameState.isPromoLoading)
                            .onChange(of: codeInput) { _, newValue in
                                codeInput = newValue.lowercased().filter { $0.isLetter || $0.isNumber }
                            }

                        Button(gameState.isPromoLoading ? "Redeeming…" : "Redeem code") {
                            gameState.redeemPromoCode(codeInput)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(codeInput.isEmpty || gameState.isPromoLoading)
                    }

                    if let message = gameState.promoStatusMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task(id: isSignedIn) {
                gameState.refreshEpic20PromoStatus()
            }
        }
    }
}
