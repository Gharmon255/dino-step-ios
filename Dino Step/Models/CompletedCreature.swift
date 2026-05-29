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
}
