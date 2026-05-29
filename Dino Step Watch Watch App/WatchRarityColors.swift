//
//  WatchRarityColors.swift
//  Dino Step Watch Watch App
//

import SwiftUI

enum WatchRarityColors {
    static func color(for rarity: WatchRarity) -> Color {
        color(forRarityString: rarity.rawValue)
    }

    static func color(forRarityString rarity: String) -> Color {
        RarityEggVisual.primaryColor(for: rarity)
    }
}
