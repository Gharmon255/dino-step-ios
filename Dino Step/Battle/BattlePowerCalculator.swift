//
//  BattlePowerCalculator.swift
//  Dino Step
//

import Foundation

struct FighterPower: Equatable {
    var combatPower: Int
    var maxHp: Int
    var attack: Int
    var packCount: Int
    var packMultiplier: Double
    var exLevel: Int
    var speciesId: String
    var displayName: String
}

enum BattlePowerCalculator {
    private static let speciesBasePower: [Rarity: Int] = [
        .common: 100,
        .uncommon: 130,
        .rare: 170,
        .epic: 220,
        .legendary: 280,
    ]

    private static let eggBonus: [Rarity: Int] = [
        .common: 0,
        .uncommon: 10,
        .rare: 20,
        .epic: 30,
        .legendary: 40,
    ]

    static func packCount(collection: [CompletedCreature], speciesId: String) -> Int {
        collection.filter { $0.definition.speciesId == speciesId }.count
    }

    static func packMultiplier(packCount: Int) -> Double {
        guard packCount > 1 else { return 1.0 }
        return 1.0 + Double(min(packCount - 1, 3)) * 0.15
    }

    static func packAbilityLabel(speciesId: String) -> String {
        if speciesId.contains("raptor") { return "Pack Hunt" }
        if speciesId.contains("triceratops") { return "Herd Stomp" }
        return "Team Up"
    }

    static func compute(fighter: CompletedCreature, collection: [CompletedCreature]) -> FighterPower {
        let base = speciesBasePower[fighter.definition.rarity] ?? 100
        let egg = eggBonus[fighter.eggRarityAtHatch] ?? 0
        let ex = fighter.exLevel * 3
        let count = packCount(collection: collection, speciesId: fighter.definition.speciesId)
        let multiplier = packMultiplier(packCount: count)
        let combatPower = Int(floor(Double(base + egg + ex) * multiplier))
        return FighterPower(
            combatPower: combatPower,
            maxHp: Int(floor(Double(combatPower) * 1.2)),
            attack: max(1, Int(floor(Double(combatPower) * 0.35))),
            packCount: count,
            packMultiplier: multiplier,
            exLevel: fighter.exLevel,
            speciesId: fighter.definition.speciesId,
            displayName: fighter.displayName
        )
    }
}
