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
}

enum Habitat: String, CaseIterable {
    case jungle = "JUNGLE"
    case plains = "PLAINS"
    case rocky = "ROCKY"
}
