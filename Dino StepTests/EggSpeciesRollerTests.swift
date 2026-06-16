import XCTest
@testable import Dino_Step

final class EggSpeciesRollerTests: XCTestCase {
    func testExcludesJustCompletedSpecies() {
        let pool = CreatureCatalog.creatures(for: .common)
        XCTAssertGreaterThan(pool.count, 1)

        let species = EggSpeciesRoller.rollSpecies(
            rarity: .common,
            excludeSpeciesIds: [pool[0].speciesId],
            collectedSpeciesIds: []
        )
        XCTAssertNotEqual(species.speciesId, pool[0].speciesId)
    }

    func testPrefersUndiscoveredInTier() {
        let pool = CreatureCatalog.creatures(for: .common)
        let collected = Set(pool.dropLast().map(\.speciesId))
        let undiscovered = pool.last!.speciesId

        for _ in 0..<20 {
            let species = EggSpeciesRoller.rollSpecies(
                rarity: .common,
                excludeSpeciesIds: [],
                collectedSpeciesIds: collected
            )
            XCTAssertEqual(species.speciesId, undiscovered)
        }
    }

    func testFallsBackWhenTierDexComplete() {
        let pool = CreatureCatalog.creatures(for: .common)
        let allCollected = Set(pool.map(\.speciesId))

        let species = EggSpeciesRoller.rollSpecies(
            rarity: .common,
            excludeSpeciesIds: [],
            collectedSpeciesIds: allCollected
        )
        XCTAssertTrue(pool.contains { $0.speciesId == species.speciesId })
    }
}
