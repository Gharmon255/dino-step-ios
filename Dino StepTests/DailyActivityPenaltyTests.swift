import XCTest
@testable import Dino_Step

final class DailyActivityPenaltyTests: XCTestCase {
    private func makeCreature(steps: Int, hatched: Bool) -> ActiveCreature {
        let definition = CreatureCatalog.creature(withSpeciesId: "tiny_raptor")!
        var creature = ActiveCreature.newEgg(definition: definition, eggRarity: .common)
        creature.currentSteps = steps
        if hatched {
            creature.currentSteps = max(creature.progression.hatchStep, steps)
        }
        return creature
    }

    func testApplyIfNeeded_belowMinimum_resetsToEggWith500Steps() {
        let creature = makeCreature(steps: 20_000, hatched: true)
        let result = DailyActivityPenalty.applyIfNeeded(yesterdaySteps: 4_999, activeCreature: creature)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.creature.currentSteps, 500)
        XCTAssertFalse(GameLogic.isHatched(result!.creature))
    }

    func testApplyIfNeeded_atMinimum_noPenalty() {
        let creature = makeCreature(steps: 20_000, hatched: true)
        XCTAssertNil(DailyActivityPenalty.applyIfNeeded(yesterdaySteps: 5_000, activeCreature: creature))
    }
}
