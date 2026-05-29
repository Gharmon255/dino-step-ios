//
//  RarityBadge.swift
//  Dino Step
//

import SwiftUI

struct RarityBadge: View {
    let rarity: Rarity

    var body: some View {
        Text(rarity.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(RarityColors.color(for: rarity).opacity(0.2)))
            .foregroundStyle(RarityColors.color(for: rarity))
    }
}
