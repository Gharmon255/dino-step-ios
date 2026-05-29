//
//  RarityColors.swift
//  Dino Step
//

import SwiftUI

enum RarityColors {
    static func color(for rarity: Rarity) -> Color {
        RarityEggVisual.primaryColor(for: rarity.rawValue)
    }

    static func eggStyle(for rarity: Rarity) -> RarityEggVisual.Style {
        RarityEggVisual.style(for: rarity.rawValue)
    }

    static func cardGlowOpacity(for rarity: Rarity) -> Double {
        switch rarity {
        case .common, .uncommon: 0
        case .rare: 0.08
        case .epic: 0.14
        case .legendary: 0.22
        }
    }
}
