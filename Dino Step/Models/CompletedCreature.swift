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

    var displayName: String {
        CreatureNickname.normalize(nickname) ?? definition.name
    }
}
