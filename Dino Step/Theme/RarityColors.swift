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

    /// Full-screen wash behind Home (and other run screens). Stronger for higher rarities.
    static func screenTintOpacity(for rarity: Rarity, colorScheme: ColorScheme) -> Double {
        let base: Double = switch rarity {
        case .common: 0.06
        case .uncommon: 0.10
        case .rare: 0.16
        case .epic: 0.20
        case .legendary: 0.24
        }
        return colorScheme == .dark ? base + 0.06 : base
    }

    static func screenBaseColor(colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            Color(red: 0.07, green: 0.09, blue: 0.08)
        } else {
            Color(.systemGroupedBackground)
        }
    }
}

/// Ambient rarity backdrop — egg tint before hatch, creature tint after.
struct RarityScreenBackground: View {
    let rarity: Rarity
    @Environment(\.colorScheme) private var colorScheme

    private var eggStyle: RarityEggVisual.Style {
        RarityColors.eggStyle(for: rarity)
    }

    var body: some View {
        ZStack {
            RarityColors.screenBaseColor(colorScheme: colorScheme)

            LinearGradient(
                colors: [
                    eggStyle.glow.opacity(RarityColors.screenTintOpacity(for: rarity, colorScheme: colorScheme)),
                    eggStyle.primary.opacity(RarityColors.screenTintOpacity(for: rarity, colorScheme: colorScheme) * 0.55),
                    .clear,
                ],
                startPoint: .top,
                endPoint: .center
            )

            RadialGradient(
                colors: [
                    eggStyle.glow.opacity(RarityColors.screenTintOpacity(for: rarity, colorScheme: colorScheme) * 0.85),
                    .clear,
                ],
                center: .top,
                startRadius: 20,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}
