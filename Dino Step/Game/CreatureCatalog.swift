//
//  CreatureCatalog.swift
//  Dino Step
//

import Foundation

enum CreatureCatalog {
    static let assetBackedSpeciesIds = CreatureAssetVisual.assetBackedSpeciesIds

    static let allCreatures: [CreatureDefinition] = commonCreatures
        + uncommonCreatures
        + rareCreatures
        + epicCreatures
        + legendaryCreatures

    static func creatures(for rarity: Rarity) -> [CreatureDefinition] {
        switch rarity {
        case .common: commonCreatures
        case .uncommon: uncommonCreatures
        case .rare: rareCreatures
        case .epic: epicCreatures
        case .legendary: legendaryCreatures
        }
    }

    static func creature(withId id: UUID) -> CreatureDefinition? {
        allCreatures.first { $0.id == id }
    }

    static func creature(withSpeciesId speciesId: String) -> CreatureDefinition? {
        let resolved = legacySpeciesNameAliases[speciesId] ?? speciesId
        return allCreatures.first { $0.speciesId == resolved }
    }

    static func creature(named name: String) -> CreatureDefinition? {
        if let speciesId = legacySpeciesNameAliases[name] {
            return creature(withSpeciesId: speciesId)
        }
        return allCreatures.first { $0.name == name }
    }

    static let commonCreatures: [CreatureDefinition] = [
        creature(1, "Tiny Raptor", .common, .jungle, 8000, 1600, 4000, speciesId: "tiny_raptor"),
        creature(2, "Triceratops", .common, .plains, 10000, 2000, 5000, speciesId: "triceratops"),
        creature(3, "Ankylosaurus", .common, .rocky, 12000, 2400, 6000, speciesId: "ankylosaurus"),
        creature(4, "Parasaurolophus", .common, .forest, 11000, 2200, 5500, speciesId: "parasaurolophus"),
        creature(5, "Pachycephalosaurus", .common, .rocky, 12500, 2500, 6250, speciesId: "pachycephalosaurus"),
        creature(6, "Gallimimus", .common, .plains, 9000, 1800, 4500),
    ]

    static let uncommonCreatures: [CreatureDefinition] = [
        creature(7, "Stegosaurus", .uncommon, .forest, 18000, 3600, 9000, speciesId: "stegosaurus"),
        creature(8, "Pteranodon", .uncommon, .mountain, 22000, 4400, 11000, speciesId: "pteranodon"),
        creature(9, "Dilophosaurus", .uncommon, .jungle, 20000, 4000, 10000, speciesId: "dilophosaurus"),
        creature(10, "Iguanodon", .uncommon, .forest, 19000, 3800, 9500, speciesId: "iguanodon"),
        creature(11, "Carnotaurus", .uncommon, .volcano, 24000, 4800, 12000, speciesId: "carnotaurus"),
        creature(12, "Baryonyx", .uncommon, .swamp, 25000, 5000, 12500),
        creature(29, "Brachiosaurus", .uncommon, .plains, 20000, 4000, 10000, speciesId: "brachiosaurus"),
    ]

    static let rareCreatures: [CreatureDefinition] = [
        creature(13, "T-Rex", .rare, .volcano, 50000, 10000, 25000, speciesId: "trex"),
        creature(14, "Spinosaurus", .rare, .swamp, 60000, 12000, 30000, speciesId: "spinosaurus"),
        creature(15, "Velociraptor Alpha", .rare, .jungle, 45000, 9000, 22500),
        creature(16, "Allosaurus", .rare, .rocky, 48000, 9600, 24000, speciesId: "allosaurus"),
        creature(17, "Therizinosaurus", .rare, .forest, 55000, 11000, 27500),
        creature(18, "Mosasaurus", .rare, .ocean, 65000, 13000, 32500, speciesId: "mosasaurus"),
    ]

    static let epicCreatures: [CreatureDefinition] = [
        creature(19, "Giganotosaurus", .epic, .plains, 85000, 17000, 42500),
        creature(20, "Quetzalcoatlus", .epic, .mountain, 90000, 18000, 45000),
        creature(21, "Indominus Rex Style Hybrid", .epic, .lab, 95000, 19000, 47500, speciesId: "indominus_hybrid"),
        creature(22, "Ancient Spinosaurus", .epic, .swamp, 100000, 20000, 50000),
    ]

    static let legendaryCreatures: [CreatureDefinition] = [
        creature(23, "Volcanic T-Rex", .legendary, .volcano, 125000, 25000, 62500),
        creature(24, "Frost Raptor", .legendary, .ice, 110000, 22000, 55000),
        creature(25, "Shadow Triceratops", .legendary, .dark, 130000, 26000, 65000),
        creature(26, "Titanosaur", .legendary, .plains, 150000, 30000, 75000),
        creature(27, "Cosmic Pterodactyl", .legendary, .sky, 175000, 35000, 87500),
        creature(28, "Ancient Apex Rex", .legendary, .volcano, 200000, 40000, 100000),
    ]

    /// Legacy display names, slugs, and dev-picker values mapped to canonical species IDs.
    private static let legacySpeciesNameAliases: [String: String] = [
        "Pterodactyl": "pteranodon",
        "pterodactyl": "pteranodon",
        "indominus_rex_style_hybrid": "indominus_hybrid",
    ]

    private static func creature(
        _ index: Int,
        _ name: String,
        _ rarity: Rarity,
        _ habitat: Habitat,
        _ totalSteps: Int,
        _ hatchStep: Int,
        _ juvenileStep: Int,
        speciesId: String? = nil
    ) -> CreatureDefinition {
        CreatureDefinition(
            id: UUID(uuidString: String(format: "A100%04X-0000-4000-8000-%012X", index, index))!,
            speciesId: speciesId ?? defaultSpeciesId(from: name),
            name: name,
            rarity: rarity,
            habitat: habitat,
            totalStepsRequired: totalSteps,
            hatchStep: hatchStep,
            juvenileStep: juvenileStep
        )
    }

    private static func defaultSpeciesId(from name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
    }
}
