import XCTest
@testable import Dino_Step

final class CreatureAssetVisualTests: XCTestCase {
    func testAssetBackedSpeciesCount() {
        XCTAssertEqual(CreatureAssetVisual.assetBackedSpeciesIds.count, 34)
    }

    func testNormalizedSpeciesId_aliases() {
        XCTAssertEqual(CreatureAssetVisual.normalizedSpeciesId(from: "t_rex"), "trex")
        XCTAssertEqual(CreatureAssetVisual.normalizedSpeciesId(from: "Pterodactyl"), "pteranodon")
        XCTAssertEqual(CreatureAssetVisual.normalizedSpeciesId(from: "indominus_rex_style_hybrid"), "indominus_hybrid")
    }

    func testVariantLegendaries_doNotAliasToBaseSpecies() {
        XCTAssertEqual(CreatureAssetVisual.normalizedSpeciesId(from: "ancient_apex_rex"), "ancient_apex_rex")
        XCTAssertNotEqual(
            CreatureAssetVisual.normalizedSpeciesId(from: "ancient_apex_rex"),
            CreatureAssetVisual.normalizedSpeciesId(from: "trex")
        )
    }

    func testAssetName_forBackedSpecies() {
        XCTAssertEqual(CreatureAssetVisual.assetName(forSpeciesId: "frost_raptor", stage: "ADULT"), "dino_frost_raptor_adult")
        XCTAssertNil(CreatureAssetVisual.assetName(forSpeciesId: "unknown_species", stage: "baby"))
    }
}
