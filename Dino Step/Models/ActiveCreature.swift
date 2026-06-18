//
//  ActiveCreature.swift
//  Dino Step
//

import Foundation

struct ActiveCreature {
    let eggRarity: Rarity
    let definition: CreatureDefinition
    let progression: ProgressionThresholds
    var currentSteps: Int
    let startedAt: Date
    var nickname: String?

    static func newEgg(
        definition: CreatureDefinition,
        eggRarity: Rarity,
        economyVersion: Int = CreatureEconomy.currentEconomy
    ) -> ActiveCreature {
        ActiveCreature(
            eggRarity: eggRarity,
            definition: definition,
            progression: CreatureEconomy.thresholds(for: definition, economyVersion: economyVersion),
            currentSteps: 0,
            startedAt: Date(),
            nickname: nil
        )
    }

    var displayName: String {
        CreatureNickname.activeDisplayName(
            speciesName: definition.name,
            nickname: nickname,
            isHatched: GameLogic.isHatched(self),
            mysteryEggTitle: eggRarity.mysteryEggTitle
        )
    }

    var speciesSubtitle: String? {
        CreatureNickname.speciesSubtitle(
            speciesName: definition.name,
            nickname: nickname,
            isHatched: GameLogic.isHatched(self)
        )
    }
}
