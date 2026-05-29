//
//  ActiveCreature.swift
//  Dino Step
//

import Foundation

struct ActiveCreature {
    let eggRarity: Rarity
    let definition: CreatureDefinition
    var currentSteps: Int
    let startedAt: Date
}
