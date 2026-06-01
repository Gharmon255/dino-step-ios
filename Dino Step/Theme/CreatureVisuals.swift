//
//  CreatureVisuals.swift
//  Dino Step
//

import SwiftUI

enum CreatureVisuals {
    static func visualIdentity(for creature: CreatureDefinition) -> CreatureVisualIdentity {
        let profile = profile(for: creature)
        let prefix = assetPrefix(for: creature.name)

        return CreatureVisualIdentity(
            creatureId: creature.id,
            shortCode: profile.shortCode,
            baseEmoji: profile.baseEmoji,
            primaryColor: habitatColor(creature.habitat, variant: profile.colorVariant),
            secondaryColor: habitatSecondaryColor(creature.habitat, variant: profile.colorVariant),
            silhouetteLabel: creature.name,
            eggAssetKey: "\(prefix)_egg",
            babyAssetKey: "\(prefix)_baby",
            juvenileAssetKey: "\(prefix)_juvenile",
            adultAssetKey: "\(prefix)_adult"
        )
    }

    static func stageVisual(
        for creature: CreatureDefinition,
        stage: GrowthStage,
        eggRarity: Rarity? = nil
    ) -> StageVisual {
        let identity = visualIdentity(for: creature)

        switch stage {
        case .egg:
            let accent = eggRarity.map { RarityColors.color(for: $0) } ?? identity.primaryColor
            return StageVisual(
                displayEmoji: "🥚",
                label: eggRarity?.mysteryEggTitle ?? "Mystery Egg",
                size: 120,
                emojiFontSize: 64,
                labelFontSize: 0,
                stageDescription: "Incubating",
                accentColor: accent,
                secondaryColor: identity.secondaryColor
            )
        case .baby:
            return StageVisual(
                displayEmoji: identity.baseEmoji,
                label: identity.silhouetteLabel,
                size: 80,
                emojiFontSize: 48,
                labelFontSize: 13,
                stageDescription: "Hatchling",
                accentColor: identity.primaryColor,
                secondaryColor: identity.secondaryColor
            )
        case .juvenile:
            return StageVisual(
                displayEmoji: identity.baseEmoji,
                label: identity.silhouetteLabel,
                size: 104,
                emojiFontSize: 64,
                labelFontSize: 15,
                stageDescription: "Juvenile",
                accentColor: identity.primaryColor,
                secondaryColor: identity.secondaryColor
            )
        case .adult:
            return StageVisual(
                displayEmoji: identity.baseEmoji,
                label: identity.silhouetteLabel,
                size: 128,
                emojiFontSize: 80,
                labelFontSize: 17,
                stageDescription: "Adult",
                accentColor: identity.primaryColor,
                secondaryColor: identity.secondaryColor
            )
        }
    }

    // MARK: - Creature Profiles

    private struct CreatureVisualProfile {
        let shortCode: String
        let baseEmoji: String
        let colorVariant: Int
    }

    private static func profile(for creature: CreatureDefinition) -> CreatureVisualProfile {
        profilesByName[creature.name] ?? CreatureVisualProfile(
            shortCode: initials(from: creature.name),
            baseEmoji: "🦖",
            colorVariant: 0
        )
    }

    private static let profilesByName: [String: CreatureVisualProfile] = [
        "Tiny Raptor": .init(shortCode: "TIR", baseEmoji: "🦖", colorVariant: 0),
        "Triceratops": .init(shortCode: "TRI", baseEmoji: "🦕", colorVariant: 1),
        "Ankylosaurus": .init(shortCode: "ANK", baseEmoji: "🦕", colorVariant: 2),
        "Parasaurolophus": .init(shortCode: "PAR", baseEmoji: "🦕", colorVariant: 0),
        "Pachycephalosaurus": .init(shortCode: "PCH", baseEmoji: "🦕", colorVariant: 1),
        "Gallimimus": .init(shortCode: "GAL", baseEmoji: "🦖", colorVariant: 2),
        "Stegosaurus": .init(shortCode: "STE", baseEmoji: "🦕", colorVariant: 0),
        "Brachiosaurus": .init(shortCode: "BRA", baseEmoji: "🦕", colorVariant: 1),
        "Pteranodon": .init(shortCode: "PTN", baseEmoji: "🦖", colorVariant: 1),
        "Pterodactyl": .init(shortCode: "PTN", baseEmoji: "🦖", colorVariant: 1),
        "Dilophosaurus": .init(shortCode: "DIL", baseEmoji: "🦖", colorVariant: 2),
        "Iguanodon": .init(shortCode: "IGU", baseEmoji: "🦕", colorVariant: 0),
        "Carnotaurus": .init(shortCode: "CAR", baseEmoji: "🦖", colorVariant: 1),
        "Baryonyx": .init(shortCode: "BAR", baseEmoji: "🦖", colorVariant: 2),
        "T-Rex": .init(shortCode: "TRX", baseEmoji: "🦖", colorVariant: 0),
        "Spinosaurus": .init(shortCode: "SPI", baseEmoji: "🦖", colorVariant: 1),
        "Velociraptor Alpha": .init(shortCode: "VRA", baseEmoji: "🦖", colorVariant: 2),
        "Allosaurus": .init(shortCode: "ALL", baseEmoji: "🦖", colorVariant: 0),
        "Therizinosaurus": .init(shortCode: "THZ", baseEmoji: "🦕", colorVariant: 1),
        "Mosasaurus": .init(shortCode: "MOS", baseEmoji: "🦖", colorVariant: 2),
        "Giganotosaurus": .init(shortCode: "GIG", baseEmoji: "🦖", colorVariant: 0),
        "Quetzalcoatlus": .init(shortCode: "QUZ", baseEmoji: "🦖", colorVariant: 1),
        "Indominus Rex Style Hybrid": .init(shortCode: "IRH", baseEmoji: "🦖", colorVariant: 2),
        "Ancient Spinosaurus": .init(shortCode: "ASP", baseEmoji: "🦖", colorVariant: 0),
        "Volcanic T-Rex": .init(shortCode: "VTX", baseEmoji: "🦖", colorVariant: 1),
        "Frost Raptor": .init(shortCode: "FRP", baseEmoji: "🦖", colorVariant: 2),
        "Shadow Triceratops": .init(shortCode: "STR", baseEmoji: "🦕", colorVariant: 0),
        "Titanosaur": .init(shortCode: "TIT", baseEmoji: "🦕", colorVariant: 1),
        "Cosmic Pterodactyl": .init(shortCode: "CPT", baseEmoji: "🦖", colorVariant: 2),
        "Ancient Apex Rex": .init(shortCode: "AAR", baseEmoji: "🦖", colorVariant: 0),
    ]

    // MARK: - Helpers

    private static func assetPrefix(for name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
    }

    private static func initials(from name: String) -> String {
        let words = name.split(separator: " ")
        let letters = words.prefix(3).compactMap(\.first)
        return String(letters).uppercased()
    }

    private static func habitatColor(_ habitat: Habitat, variant: Int) -> Color {
        let bases: [Color]
        switch habitat {
        case .jungle:
            bases = [
                Color(red: 0.22, green: 0.58, blue: 0.32),
                Color(red: 0.28, green: 0.62, blue: 0.38),
                Color(red: 0.18, green: 0.52, blue: 0.30),
            ]
        case .plains:
            bases = [
                Color(red: 0.62, green: 0.58, blue: 0.28),
                Color(red: 0.68, green: 0.62, blue: 0.34),
                Color(red: 0.56, green: 0.52, blue: 0.24),
            ]
        case .rocky:
            bases = [
                Color(red: 0.48, green: 0.44, blue: 0.40),
                Color(red: 0.54, green: 0.48, blue: 0.44),
                Color(red: 0.42, green: 0.40, blue: 0.36),
            ]
        case .forest:
            bases = [
                Color(red: 0.18, green: 0.45, blue: 0.28),
                Color(red: 0.24, green: 0.50, blue: 0.32),
                Color(red: 0.14, green: 0.40, blue: 0.24),
            ]
        case .mountain:
            bases = [
                Color(red: 0.38, green: 0.48, blue: 0.58),
                Color(red: 0.44, green: 0.52, blue: 0.62),
                Color(red: 0.32, green: 0.44, blue: 0.54),
            ]
        case .volcano:
            bases = [
                Color(red: 0.78, green: 0.32, blue: 0.22),
                Color(red: 0.82, green: 0.38, blue: 0.26),
                Color(red: 0.72, green: 0.28, blue: 0.18),
            ]
        case .swamp:
            bases = [
                Color(red: 0.28, green: 0.42, blue: 0.32),
                Color(red: 0.32, green: 0.46, blue: 0.36),
                Color(red: 0.24, green: 0.38, blue: 0.28),
            ]
        case .ocean:
            bases = [
                Color(red: 0.18, green: 0.42, blue: 0.72),
                Color(red: 0.22, green: 0.46, blue: 0.76),
                Color(red: 0.14, green: 0.38, blue: 0.66),
            ]
        case .ice:
            bases = [
                Color(red: 0.45, green: 0.68, blue: 0.82),
                Color(red: 0.50, green: 0.72, blue: 0.86),
                Color(red: 0.40, green: 0.64, blue: 0.78),
            ]
        case .dark:
            bases = [
                Color(red: 0.32, green: 0.28, blue: 0.42),
                Color(red: 0.36, green: 0.32, blue: 0.46),
                Color(red: 0.28, green: 0.24, blue: 0.38),
            ]
        case .sky:
            bases = [
                Color(red: 0.52, green: 0.58, blue: 0.88),
                Color(red: 0.56, green: 0.62, blue: 0.92),
                Color(red: 0.48, green: 0.54, blue: 0.84),
            ]
        case .lab:
            bases = [
                Color(red: 0.22, green: 0.62, blue: 0.58),
                Color(red: 0.26, green: 0.66, blue: 0.62),
                Color(red: 0.18, green: 0.58, blue: 0.54),
            ]
        }

        return bases[variant % bases.count]
    }

    private static func habitatSecondaryColor(_ habitat: Habitat, variant: Int) -> Color {
        habitatColor(habitat, variant: (variant + 1) % 3).opacity(0.45)
    }
}
