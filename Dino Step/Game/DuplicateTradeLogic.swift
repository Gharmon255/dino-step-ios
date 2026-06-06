//
//  DuplicateTradeLogic.swift
//  Dino Step
//

import Foundation

struct DuplicateTradeOffer: Equatable {
    let speciesId: String
    let speciesName: String
    let storedCount: Int
    let rewardEggRarity: Rarity

    var tradeButtonTitle: String {
        "Trade 2× \(speciesName) for \(rewardEggRarity.mysteryEggTitle)"
    }

    var helperText: String {
        "Uses \(storedCount.formatted()) in your collection plus this adult."
    }

    var confirmationMessage: String {
        "Trade 2× \(speciesName) for a \(rewardEggRarity.mysteryEggTitle)? " +
            "One stored adult and this one will be removed. This cannot be undone."
    }
}

enum DuplicateTradeLogic {
    static func offer(
        activeCreature: ActiveCreature,
        currentStage: GrowthStage,
        completedCreatures: [CompletedCreature]
    ) -> DuplicateTradeOffer? {
        guard currentStage == .adult else { return nil }
        guard GameLogic.isHatched(activeCreature) else { return nil }

        let speciesId = activeCreature.definition.speciesId
        let storedCount = collectionCount(speciesId: speciesId, in: completedCreatures)
        guard storedCount >= 1 else { return nil }

        guard let rewardEggRarity = nextEggRarity(after: activeCreature.definition.rarity) else {
            return nil
        }

        return DuplicateTradeOffer(
            speciesId: speciesId,
            speciesName: activeCreature.definition.name,
            storedCount: storedCount,
            rewardEggRarity: rewardEggRarity
        )
    }

    static func nextEggRarity(after speciesRarity: Rarity) -> Rarity? {
        switch speciesRarity {
        case .common: .uncommon
        case .uncommon: .rare
        case .rare: .epic
        case .epic: .legendary
        case .legendary: nil
        }
    }

    static func collectionCount(speciesId: String, in completed: [CompletedCreature]) -> Int {
        completed.count { $0.definition.speciesId == speciesId }
    }

    /// Removes one stored adult of [speciesId]. Prefers the oldest completion.
    @discardableResult
    static func removeOneCompleted(speciesId: String, from completed: inout [CompletedCreature]) -> Bool {
        let matching = completed.enumerated().filter { $0.element.definition.speciesId == speciesId }
        guard let oldest = matching.min(by: { $0.element.completedAt < $1.element.completedAt }) else {
            return false
        }

        completed.remove(at: oldest.offset)
        return true
    }
}
