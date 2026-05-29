//
//  EggRewardLogic.swift
//  Dino Step
//

import Foundation

struct EggRewardOutcome {
    let rarity: Rarity
    let rollPercent: Double
}

enum EggRewardLogic {
    private static let weights: [(Rarity, Double)] = [
        (.common, 65),
        (.uncommon, 22),
        (.rare, 9),
        (.epic, 3),
        (.legendary, 1),
    ]

    static func rollEggReward() -> EggRewardOutcome {
        let roll = Double.random(in: 0..<100)
        var cumulative = 0.0

        for (rarity, weight) in weights {
            cumulative += weight
            if roll < cumulative {
                return EggRewardOutcome(rarity: rarity, rollPercent: roll)
            }
        }

        return EggRewardOutcome(rarity: .legendary, rollPercent: roll)
    }
}
