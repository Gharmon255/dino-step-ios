import XCTest
@testable import Dino_Step

final class GameLogicStressTests: XCTestCase {
    func testAllCatalogSpecies_stageMathStableUnderRapidSteps() {
        for creature in CreatureCatalog.allCreatures {
            var steps = 0
            var sawEgg = false
            var sawAdult = false

            while steps <= creature.totalStepsRequired + 2_000 {
                let stage = GameLogic.calculateStage(currentSteps: steps, creatureDefinition: creature)
                let stageProgress = GameLogic.stageProgressPercent(currentSteps: steps, creatureDefinition: creature)
                let lifetimeProgress = GameLogic.progressPercent(currentSteps: steps, creatureDefinition: creature)

                XCTAssertGreaterThanOrEqual(stageProgress, 0)
                XCTAssertLessThanOrEqual(stageProgress, 100)
                XCTAssertGreaterThanOrEqual(lifetimeProgress, 0)
                XCTAssertLessThanOrEqual(lifetimeProgress, 100)

                if stage == .egg { sawEgg = true }
                if stage == .adult { sawAdult = true }

                steps += 211
            }

            XCTAssertTrue(sawEgg, "Expected egg stage for \(creature.speciesId)")
            XCTAssertTrue(sawAdult, "Expected adult stage for \(creature.speciesId)")
        }
    }

    func testEggRewardLogic_manyDeterministicRolls_validRarities() {
        let allowed = Set(Rarity.allCases)
        for roll in 0..<10_000 {
            let outcome = EggRewardLogic.rollEggReward(rollPercent: Double(roll % 100))
            XCTAssertTrue(allowed.contains(outcome.rarity))
        }
    }
}
