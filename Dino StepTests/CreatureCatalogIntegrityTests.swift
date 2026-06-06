import XCTest
@testable import Dino_Step

final class CreatureCatalogIntegrityTests: XCTestCase {
    func testAllCreatures_haveUniqueSpeciesIds() {
        let ids = CreatureCatalog.allCreatures.map(\.speciesId)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testAllCreatures_stepThresholdsOrdered() {
        for creature in CreatureCatalog.allCreatures {
            XCTAssertLessThan(creature.hatchStep, creature.juvenileStep, creature.speciesId)
            XCTAssertLessThan(creature.juvenileStep, creature.totalStepsRequired, creature.speciesId)
        }
    }

    func testAssetBackedSpecies_existInCatalog() {
        let catalogIds = Set(CreatureCatalog.allCreatures.map(\.speciesId))
        for speciesId in CreatureAssetVisual.assetBackedSpeciesIds {
            XCTAssertTrue(catalogIds.contains(speciesId), "Missing catalog entry for \(speciesId)")
        }
    }

    func testShippedAssetBackedSpecies_areMarkedAssetBacked() {
        for speciesId in CreatureAssetVisual.assetBackedSpeciesIds {
            guard let creature = CreatureCatalog.creature(withSpeciesId: speciesId) else {
                XCTFail("Missing creature for \(speciesId)")
                continue
            }
            XCTAssertTrue(creature.isAssetBacked, speciesId)
        }
    }
}
