//
//  CreatureEconomy.swift
//  Dino Step
//

import Foundation

enum CreatureEconomy {
    static let economyV1 = 1
    static let economyV2 = 2
    static let currentEconomy = economyV2

    private static let hatchFraction = 0.18
    private static let juvenileFraction = 0.45

    private static let adultTotalV2: [Rarity: Int] = [
        .common: 40_000,
        .uncommon: 65_000,
        .rare: 100_000,
        .epic: 150_000,
        .legendary: 240_000,
    ]

    private static let legacyV1BySpeciesId: [String: (Int, Int, Int)] = [
        "tiny_raptor": (1_600, 4_000, 8_000),
        "triceratops": (2_000, 5_000, 10_000),
        "ankylosaurus": (2_400, 6_000, 12_000),
        "parasaurolophus": (2_200, 5_500, 11_000),
        "pachycephalosaurus": (2_500, 6_250, 12_500),
        "gallimimus": (1_800, 4_500, 9_000),
        "compsognathus": (1_500, 3_750, 7_500),
        "stegosaurus": (3_600, 9_000, 18_000),
        "brachiosaurus": (4_000, 10_000, 20_000),
        "pteranodon": (4_400, 11_000, 22_000),
        "dilophosaurus": (4_000, 10_000, 20_000),
        "iguanodon": (3_800, 9_500, 19_000),
        "carnotaurus": (4_800, 12_000, 24_000),
        "baryonyx": (5_000, 12_500, 25_000),
        "plesiosaurus": (4_200, 10_500, 21_000),
        "trex": (10_000, 25_000, 50_000),
        "spinosaurus": (12_000, 30_000, 60_000),
        "velociraptor_alpha": (9_000, 22_500, 45_000),
        "allosaurus": (9_600, 24_000, 48_000),
        "therizinosaurus": (11_000, 27_500, 55_000),
        "mosasaurus": (13_000, 32_500, 65_000),
        "diplodocus": (10_400, 26_000, 52_000),
        "giganotosaurus": (17_000, 42_500, 85_000),
        "quetzalcoatlus": (18_000, 45_000, 90_000),
        "indominus_hybrid": (19_000, 47_500, 95_000),
        "ancient_spinosaurus": (20_000, 50_000, 100_000),
        "crystal_ceratosaurus": (18_400, 46_000, 92_000),
        "volcanic_t_rex": (25_000, 62_500, 125_000),
        "frost_raptor": (22_000, 55_000, 110_000),
        "shadow_triceratops": (26_000, 65_000, 130_000),
        "titanosaur": (30_000, 75_000, 150_000),
        "cosmic_pterodactyl": (35_000, 87_500, 175_000),
        "ancient_apex_rex": (40_000, 100_000, 200_000),
        "abyssal_mosasaurus": (38_000, 95_000, 190_000),
    ]

    static func catalogThresholds(for rarity: Rarity) -> ProgressionThresholds {
        thresholds(for: rarity, economyVersion: currentEconomy)
    }

    static func thresholds(for creature: CreatureDefinition, economyVersion: Int = currentEconomy) -> ProgressionThresholds {
        if economyVersion == economyV1 {
            return legacyV1Thresholds(for: creature.speciesId)
        }
        return thresholds(for: creature.rarity, economyVersion: economyVersion)
    }

    static func legacyV1Thresholds(for speciesId: String) -> ProgressionThresholds {
        let canonical = CreatureCatalog.creature(withSpeciesId: speciesId)?.speciesId ?? speciesId
        let values = legacyV1BySpeciesId[canonical] ?? (1_600, 4_000, 8_000)
        return ProgressionThresholds(
            hatchStep: values.0,
            juvenileStep: values.1,
            totalStepsRequired: values.2,
            economyVersion: economyV1
        )
    }

    static func thresholds(for rarity: Rarity, economyVersion: Int) -> ProgressionThresholds {
        if economyVersion == economyV1 {
            if let sample = CreatureCatalog.creatures(for: rarity).first {
                return legacyV1Thresholds(for: sample.speciesId)
            }
            return thresholdsFromTotal(8_000, economyVersion: economyV1)
        }
        let total = adultTotalV2[rarity] ?? adultTotalV2[.common]!
        return thresholdsFromTotal(total, economyVersion: economyVersion)
    }

    private static func thresholdsFromTotal(_ total: Int, economyVersion: Int) -> ProgressionThresholds {
        let hatch = max(1, Int(Double(total) * hatchFraction))
        let juvenile = max(hatch + 1, Int(Double(total) * juvenileFraction))
        return ProgressionThresholds(
            hatchStep: hatch,
            juvenileStep: juvenile,
            totalStepsRequired: total,
            economyVersion: economyVersion
        )
    }
}
