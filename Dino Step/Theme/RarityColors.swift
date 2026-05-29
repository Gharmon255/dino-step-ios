//
//  RarityColors.swift
//  Dino Step
//

import SwiftUI

enum RarityColors {
    static func color(for rarity: Rarity) -> Color {
        switch rarity {
        case .common:
            Color(red: 0.45, green: 0.62, blue: 0.38)
        case .uncommon:
            .blue
        case .rare:
            .purple
        case .epic:
            Color(red: 0.88, green: 0.38, blue: 0.55)
        case .legendary:
            Color(red: 0.92, green: 0.72, blue: 0.18)
        }
    }
}
