//
//  RarityEggVisual.swift
//  Dino Step Shared
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum RarityEggVisual {
    struct Style {
        let primary: Color
        let secondary: Color
        let glow: Color
        let speckle: Color
        let border: Color
        let showsGlow: Bool
        let showsOuterRing: Bool
        let showsSparkle: Bool
    }

    static func assetName(for rarity: String) -> String {
        switch rarity.uppercased() {
        case "COMMON": "egg_common"
        case "UNCOMMON": "egg_uncommon"
        case "RARE": "egg_rare"
        case "EPIC": "egg_epic"
        case "LEGENDARY": "egg_legendary"
        default: "egg_common"
        }
    }

    static func style(for rarity: String) -> Style {
        switch rarity.uppercased() {
        case "COMMON":
            Style(
                primary: Color(red: 0.52, green: 0.62, blue: 0.42),
                secondary: Color(red: 0.38, green: 0.48, blue: 0.34),
                glow: Color(red: 0.45, green: 0.62, blue: 0.38),
                speckle: Color(red: 0.30, green: 0.38, blue: 0.28).opacity(0.45),
                border: Color(red: 0.35, green: 0.45, blue: 0.32),
                showsGlow: false,
                showsOuterRing: false,
                showsSparkle: false
            )
        case "UNCOMMON":
            Style(
                primary: Color(red: 0.35, green: 0.58, blue: 0.95),
                secondary: Color(red: 0.18, green: 0.38, blue: 0.78),
                glow: .blue,
                speckle: Color.white.opacity(0.25),
                border: Color(red: 0.15, green: 0.35, blue: 0.72),
                showsGlow: true,
                showsOuterRing: false,
                showsSparkle: false
            )
        case "RARE":
            Style(
                primary: Color(red: 0.62, green: 0.38, blue: 0.92),
                secondary: Color(red: 0.42, green: 0.22, blue: 0.72),
                glow: .purple,
                speckle: Color.white.opacity(0.22),
                border: Color(red: 0.38, green: 0.18, blue: 0.62),
                showsGlow: true,
                showsOuterRing: true,
                showsSparkle: false
            )
        case "EPIC":
            Style(
                primary: Color(red: 0.95, green: 0.42, blue: 0.58),
                secondary: Color(red: 0.88, green: 0.28, blue: 0.18),
                glow: Color(red: 0.95, green: 0.45, blue: 0.25),
                speckle: Color.white.opacity(0.28),
                border: Color(red: 0.78, green: 0.22, blue: 0.42),
                showsGlow: true,
                showsOuterRing: true,
                showsSparkle: true
            )
        case "LEGENDARY":
            Style(
                primary: Color(red: 0.98, green: 0.82, blue: 0.28),
                secondary: Color(red: 0.88, green: 0.58, blue: 0.12),
                glow: Color(red: 0.98, green: 0.78, blue: 0.18),
                speckle: Color.white.opacity(0.35),
                border: Color(red: 0.82, green: 0.62, blue: 0.10),
                showsGlow: true,
                showsOuterRing: true,
                showsSparkle: true
            )
        default:
            style(for: "COMMON")
        }
    }

    static func primaryColor(for rarity: String) -> Color {
        style(for: rarity).primary
    }

    static func assetIsAvailable(named name: String) -> Bool {
#if canImport(UIKit)
        UIImage(named: name) != nil
#else
        false
#endif
    }

    static func shouldUseAssetImage(for rarity: String) -> Bool {
#if os(iOS) || os(watchOS)
        assetIsAvailable(named: assetName(for: rarity))
#else
        false
#endif
    }
}

struct EggShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        return path
    }
}

struct RarityEggPlaceholderView: View {
    let style: RarityEggVisual.Style
    let eggWidth: CGFloat
    let eggHeight: CGFloat
    let compact: Bool

    var body: some View {
        EggShape()
            .fill(
                LinearGradient(
                    colors: [style.primary, style.secondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: eggWidth, height: eggHeight)
            .overlay {
                EggShape()
                    .stroke(style.border, lineWidth: compact ? 1.5 : 2.5)
            }
            .overlay {
                speckleOverlay
            }
            .overlay {
                EggShape()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.28), .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: eggWidth * 0.42, height: eggHeight * 0.48)
                    .offset(x: -eggWidth * 0.14, y: -eggHeight * 0.16)
                    .frame(width: eggWidth, height: eggHeight)
                    .clipShape(EggShape())
            }
    }

    @ViewBuilder
    private var speckleOverlay: some View {
        ZStack {
            Circle()
                .fill(style.speckle)
                .frame(width: compact ? 3 : 5, height: compact ? 3 : 5)
                .offset(x: -eggWidth * 0.12, y: eggHeight * 0.08)
            Circle()
                .fill(style.speckle)
                .frame(width: compact ? 2 : 4, height: compact ? 2 : 4)
                .offset(x: eggWidth * 0.10, y: eggHeight * 0.14)
            Circle()
                .fill(style.speckle)
                .frame(width: compact ? 2 : 3, height: compact ? 2 : 3)
                .offset(x: eggWidth * 0.04, y: -eggHeight * 0.04)
        }
        .frame(width: eggWidth, height: eggHeight)
        .clipShape(EggShape())
    }
}

struct RarityEggView: View {
    let rarity: String
    var size: CGFloat = 120
    var compact: Bool = false
    var crackLevel: Int = 0

    private var style: RarityEggVisual.Style {
        RarityEggVisual.style(for: rarity)
    }

    private var assetName: String {
        RarityEggVisual.assetName(for: rarity)
    }

    private var usesAssetImage: Bool {
        RarityEggVisual.shouldUseAssetImage(for: rarity)
    }

    private var eggWidth: CGFloat { size }
    private var eggHeight: CGFloat { compact ? size * 1.18 : size * 1.22 }

    var body: some View {
        ZStack {
            if !usesAssetImage, style.showsGlow {
                EggShape()
                    .fill(style.glow.opacity(compact ? 0.28 : 0.38))
                    .frame(width: eggWidth * 1.12, height: eggHeight * 1.08)
                    .blur(radius: compact ? 4 : 10)
            }

            if !usesAssetImage, style.showsOuterRing {
                EggShape()
                    .stroke(style.primary.opacity(0.55), lineWidth: compact ? 1.5 : 2.5)
                    .frame(width: eggWidth * 1.14, height: eggHeight * 1.1)
            }

            if usesAssetImage {
                ZStack(alignment: .bottom) {
                    if style.showsGlow, !compact {
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        style.glow.opacity(0.42),
                                        style.glow.opacity(0.12),
                                        .clear,
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: eggWidth * 0.34
                                )
                            )
                            .frame(width: eggWidth * 0.72, height: eggHeight * 0.14)
                            .offset(y: eggHeight * 0.06)
                            .blur(radius: 5)
                    }

                    Image(assetName)
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFit()
                        .frame(width: eggWidth, height: eggHeight)
                }
            } else {
                RarityEggPlaceholderView(
                    style: style,
                    eggWidth: eggWidth,
                    eggHeight: eggHeight,
                    compact: compact
                )
            }

            if !usesAssetImage, style.showsSparkle, !compact {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .offset(x: eggWidth * 0.28, y: -eggHeight * 0.22)
            }

            EggCrackOverlay(
                crackLevel: crackLevel,
                width: eggWidth,
                height: eggHeight
            )
        }
        .frame(width: eggWidth * 1.2, height: eggHeight * 1.15)
    }
}
