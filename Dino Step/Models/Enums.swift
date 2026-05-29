//
//  Enums.swift
//  Dino Step
//

import Foundation

enum GrowthStage: String, CaseIterable {
    case egg = "EGG"
    case baby = "BABY"
    case juvenile = "JUVENILE"
    case adult = "ADULT"
}

enum Rarity: String, CaseIterable {
    case common = "COMMON"
    case uncommon = "UNCOMMON"
    case rare = "RARE"
    case epic = "EPIC"
    case legendary = "LEGENDARY"

    var displayName: String {
        switch self {
        case .common: "Common"
        case .uncommon: "Uncommon"
        case .rare: "Rare"
        case .epic: "Epic"
        case .legendary: "Legendary"
        }
    }

    var mysteryEggTitle: String {
        "Mystery \(displayName) Egg"
    }
}

enum Habitat: String, CaseIterable {
    case jungle = "JUNGLE"
    case plains = "PLAINS"
    case rocky = "ROCKY"
    case forest = "FOREST"
    case mountain = "MOUNTAIN"
    case volcano = "VOLCANO"
    case swamp = "SWAMP"
    case ocean = "OCEAN"
    case ice = "ICE"
    case dark = "DARK"
    case sky = "SKY"
    case lab = "LAB"
}
