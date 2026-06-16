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
        creature(1, "Tiny Raptor", .common, .jungle, speciesId: "tiny_raptor"),
        creature(2, "Triceratops", .common, .plains, speciesId: "triceratops"),
        creature(3, "Ankylosaurus", .common, .rocky, speciesId: "ankylosaurus"),
        creature(4, "Parasaurolophus", .common, .forest, speciesId: "parasaurolophus"),
        creature(5, "Pachycephalosaurus", .common, .rocky, speciesId: "pachycephalosaurus"),
        creature(6, "Gallimimus", .common, .plains, speciesId: "gallimimus"),
        creature(30, "Compsognathus", .common, .jungle, speciesId: "compsognathus"),
    ]

    static let uncommonCreatures: [CreatureDefinition] = [
        creature(7, "Stegosaurus", .uncommon, .forest, speciesId: "stegosaurus"),
        creature(8, "Pteranodon", .uncommon, .mountain, speciesId: "pteranodon"),
        creature(9, "Dilophosaurus", .uncommon, .jungle, speciesId: "dilophosaurus"),
        creature(10, "Iguanodon", .uncommon, .forest, speciesId: "iguanodon"),
        creature(11, "Carnotaurus", .uncommon, .volcano, speciesId: "carnotaurus"),
        creature(12, "Baryonyx", .uncommon, .swamp, speciesId: "baryonyx"),
        creature(29, "Brachiosaurus", .uncommon, .plains, speciesId: "brachiosaurus"),
        creature(31, "Plesiosaurus", .uncommon, .ocean, speciesId: "plesiosaurus"),
    ]

    static let rareCreatures: [CreatureDefinition] = [
        creature(13, "T-Rex", .rare, .volcano, speciesId: "trex"),
        creature(14, "Spinosaurus", .rare, .swamp, speciesId: "spinosaurus"),
        creature(15, "Velociraptor Alpha", .rare, .jungle, speciesId: "velociraptor_alpha"),
        creature(16, "Allosaurus", .rare, .rocky, speciesId: "allosaurus"),
        creature(17, "Therizinosaurus", .rare, .forest, speciesId: "therizinosaurus"),
        creature(18, "Mosasaurus", .rare, .ocean, speciesId: "mosasaurus"),
        creature(32, "Diplodocus", .rare, .plains, speciesId: "diplodocus"),
    ]

    static let epicCreatures: [CreatureDefinition] = [
        creature(19, "Giganotosaurus", .epic, .plains, speciesId: "giganotosaurus"),
        creature(20, "Quetzalcoatlus", .epic, .mountain, speciesId: "quetzalcoatlus"),
        creature(21, "Indominus Rex Style Hybrid", .epic, .lab, speciesId: "indominus_hybrid"),
        creature(22, "Ancient Spinosaurus", .epic, .swamp),
        creature(33, "Crystal Ceratosaurus", .epic, .ice, speciesId: "crystal_ceratosaurus"),
    ]

    static let legendaryCreatures: [CreatureDefinition] = [
        creature(23, "Volcanic T-Rex", .legendary, .volcano),
        creature(24, "Frost Raptor", .legendary, .ice),
        creature(25, "Shadow Triceratops", .legendary, .dark),
        creature(26, "Titanosaur", .legendary, .plains),
        creature(27, "Cosmic Pterodactyl", .legendary, .sky),
        creature(28, "Ancient Apex Rex", .legendary, .volcano),
        creature(34, "Abyssal Mosasaurus", .legendary, .ocean, speciesId: "abyssal_mosasaurus"),
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
        speciesId: String? = nil
    ) -> CreatureDefinition {
        let thresholds = CreatureEconomy.catalogThresholds(for: rarity)
        return CreatureDefinition(
            id: UUID(uuidString: String(format: "A100%04X-0000-4000-8000-%012X", index, index))!,
            speciesId: speciesId ?? defaultSpeciesId(from: name),
            name: name,
            rarity: rarity,
            habitat: habitat,
            totalStepsRequired: thresholds.totalStepsRequired,
            hatchStep: thresholds.hatchStep,
            juvenileStep: thresholds.juvenileStep
        )
    }

    private static func defaultSpeciesId(from name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
    }
}
