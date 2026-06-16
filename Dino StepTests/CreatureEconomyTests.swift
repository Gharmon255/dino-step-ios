import XCTest
@testable import Dino_Step

final class CreatureEconomyTests: XCTestCase {
    func testV2CommonAdultTotal() {
        let thresholds = CreatureEconomy.catalogThresholds(for: .common)
        XCTAssertEqual(thresholds.totalStepsRequired, 40_000)
        XCTAssertEqual(thresholds.economyVersion, CreatureEconomy.economyV2)
        XCTAssertEqual(thresholds.hatchStep, 7_200)
        XCTAssertEqual(thresholds.juvenileStep, 18_000)
    }

    func testV2LegendaryAdultTotal() {
        let thresholds = CreatureEconomy.catalogThresholds(for: .legendary)
        XCTAssertEqual(thresholds.totalStepsRequired, 240_000)
    }

    func testLegacyV1PreservesPerSpeciesTotals() {
        let trex = CreatureEconomy.legacyV1Thresholds(for: "trex")
        XCTAssertEqual(trex.totalStepsRequired, 50_000)
        XCTAssertEqual(trex.hatchStep, 10_000)
        XCTAssertEqual(trex.juvenileStep, 25_000)
        XCTAssertEqual(trex.economyVersion, CreatureEconomy.economyV1)
    }

    func testNewEggUsesV2Thresholds() {
        let definition = CreatureCatalog.creature(withSpeciesId: "tiny_raptor")!
        let egg = ActiveCreature.newEgg(definition: definition, eggRarity: .common)
        XCTAssertEqual(egg.progression.totalStepsRequired, 40_000)
        XCTAssertEqual(egg.progression.economyVersion, CreatureEconomy.economyV2)
    }
}
