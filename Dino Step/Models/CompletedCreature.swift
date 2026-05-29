//
//  CompletedCreature.swift
//  Dino Step
//

import Foundation

struct CompletedCreature: Identifiable {
    let id: UUID
    let definition: CreatureDefinition
    let completedAt: Date
}
