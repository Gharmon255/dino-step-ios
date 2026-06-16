//
//  EggSpeciesRoller.swift
//  Dino Step
//

import Foundation

enum EggSpeciesRoller {
    static func rollSpecies(
        rarity: Rarity,
        excludeSpeciesIds: Set<String> = [],
        collectedSpeciesIds: Set<String> = []
    ) -> CreatureDefinition {
        let pool = CreatureCatalog.creatures(for: rarity)
        guard !pool.isEmpty else {
            return CreatureCatalog.creatures(for: .common).randomElement()!
        }

        let withoutExcluded = pool.filter { !excludeSpeciesIds.contains($0.speciesId) }
        let undiscovered = withoutExcluded.filter { !collectedSpeciesIds.contains($0.speciesId) }
        let preferred = undiscovered.isEmpty ? withoutExcluded : undiscovered
        let finalPool = preferred.isEmpty ? pool : preferred
        return finalPool.randomElement()!
    }
}
