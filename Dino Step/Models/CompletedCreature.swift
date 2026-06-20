//
//  CompletedCreature.swift
//  Dino Step
//

import Foundation

struct CompletedCreature: Identifiable {
    let id: UUID
    let definition: CreatureDefinition
    let totalStepsCompleted: Int
    let completedAt: Date
    var nickname: String? = nil
    var eggRarityAtHatch: Rarity = .common
    var exSteps: Int = 0
    var exLevel: Int = 1

    var displayName: String {
        CreatureNickname.normalize(nickname) ?? definition.name
    }
}
