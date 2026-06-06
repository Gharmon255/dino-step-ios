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
        rollEggReward(rollPercent: Double.random(in: 0..<100))
    }

    /// Deterministic roll for unit tests (`rollPercent` in 0..<100).
    static func rollEggReward(rollPercent: Double) -> EggRewardOutcome {
        let roll = min(99.999, max(0, rollPercent))
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
