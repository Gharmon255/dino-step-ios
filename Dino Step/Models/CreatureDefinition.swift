//
//  CreatureDefinition.swift
//  Dino Step
//

import Foundation

struct CreatureDefinition: Identifiable, Equatable {
    let id: UUID
    let name: String
    let rarity: Rarity
    let habitat: Habitat
    let totalStepsRequired: Int
    let hatchStep: Int
    let juvenileStep: Int
}
