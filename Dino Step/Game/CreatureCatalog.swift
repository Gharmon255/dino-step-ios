//
//  CreatureCatalog.swift
//  Dino Step
//

import Foundation

enum CreatureCatalog {
    static let commonCreatures: [CreatureDefinition] = [
        CreatureDefinition(
            id: UUID(uuidString: "A1000001-0000-4000-8000-000000000001")!,
            name: "Tiny Raptor",
            rarity: .common,
            habitat: .jungle,
            totalStepsRequired: 8000,
            hatchStep: 1600,
            juvenileStep: 4000
        ),
        CreatureDefinition(
            id: UUID(uuidString: "A1000002-0000-4000-8000-000000000002")!,
            name: "Triceratops",
            rarity: .common,
            habitat: .plains,
            totalStepsRequired: 10000,
            hatchStep: 2000,
            juvenileStep: 5000
        ),
        CreatureDefinition(
            id: UUID(uuidString: "A1000003-0000-4000-8000-000000000003")!,
            name: "Ankylosaurus",
            rarity: .common,
            habitat: .rocky,
            totalStepsRequired: 12000,
            hatchStep: 2400,
            juvenileStep: 6000
        ),
    ]
}
