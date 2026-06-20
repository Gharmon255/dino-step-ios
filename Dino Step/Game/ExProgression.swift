//
//  ExProgression.swift
//  Dino Step
//

import Foundation

enum ExProgression {
    static let rosterExRate = 0.05
    static let maxExLevel = 50

    static func dripAmount(stepAmount: Int) -> Int {
        guard stepAmount > 0 else { return 0 }
        return Int(floor(Double(stepAmount) * rosterExRate))
    }

    static func exLevelFromSteps(_ exSteps: Int) -> Int {
        guard exSteps > 0 else { return 1 }
        var level = 1
        var accumulated = 0
        while level < maxExLevel {
            let required = stepsRequiredForLevel(level + 1)
            if accumulated + required > exSteps { break }
            accumulated += required
            level += 1
        }
        return level
    }

    static func stepsRequiredForLevel(_ level: Int) -> Int {
        500 + (level * 100)
    }

    static func applyDrip(to collection: [CompletedCreature], stepAmount: Int) -> [CompletedCreature] {
        let drip = dripAmount(stepAmount: stepAmount)
        guard drip > 0, !collection.isEmpty else { return collection }
        return collection.map { creature in
            var updated = creature
            updated.exSteps += drip
            updated.exLevel = exLevelFromSteps(updated.exSteps)
            return updated
        }
    }
}
