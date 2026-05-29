//
//  RarityGiveEggButton.swift
//  Dino Step
//

import SwiftUI

struct RarityGiveEggButton: View {
    let rarity: Rarity
    let action: () -> Void

    private var rarityColor: Color {
        RarityColors.color(for: rarity)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RarityEggView(rarity: rarity.rawValue, size: 30, compact: true)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Give \(rarity.displayName) Egg")
                        .font(.subheadline.weight(.semibold))
                    Text(rarity.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [rarityColor, rarityColor.opacity(0.72)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
