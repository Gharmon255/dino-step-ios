import XCTest
@testable import Dino_Step

final class DuplicateTradeLogicTests: XCTestCase {
    private var tinyRaptorDefinition: CreatureDefinition {
        CreatureCatalog.creature(withSpeciesId: "tiny_raptor")!
    }

    private func adultTinyRaptor(steps: Int = 8_000) -> ActiveCreature {
        ActiveCreature(
            eggRarity: .common,
            definition: tinyRaptorDefinition,
            currentSteps: steps,
            startedAt: Date()
        )
    }

    private func completedTinyRaptor(daysAgo: Int = 1) -> CompletedCreature {
        CompletedCreature(
            id: UUID(),
            definition: tinyRaptorDefinition,
            totalStepsCompleted: 8_000,
            completedAt: Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        )
    }

    func testOffer_noStoredCopy_notEligible() {
        let offer = DuplicateTradeLogic.offer(
            activeCreature: adultTinyRaptor(),
            currentStage: .adult,
            completedCreatures: []
        )
        XCTAssertNil(offer)
    }

    func testOffer_oneStoredCopy_secondAdultEligible() {
        let offer = DuplicateTradeLogic.offer(
            activeCreature: adultTinyRaptor(),
            currentStage: .adult,
            completedCreatures: [completedTinyRaptor()]
        )
        XCTAssertEqual(offer?.speciesId, "tiny_raptor")
        XCTAssertEqual(offer?.storedCount, 1)
        XCTAssertEqual(offer?.rewardEggRarity, .uncommon)
    }

    func testOffer_twoStoredCopies_thirdAdultEligible() {
        let offer = DuplicateTradeLogic.offer(
            activeCreature: adultTinyRaptor(),
            currentStage: .adult,
            completedCreatures: [
                completedTinyRaptor(daysAgo: 3),
                completedTinyRaptor(daysAgo: 1),
            ]
        )
        XCTAssertEqual(offer?.storedCount, 2)
        XCTAssertEqual(offer?.rewardEggRarity, .uncommon)
    }

    func testOffer_differentSpecies_notEligible() {
        let stego = CreatureCatalog.creature(withSpeciesId: "stegosaurus")!
        let active = ActiveCreature(
            eggRarity: .uncommon,
            definition: stego,
            currentSteps: stego.totalStepsRequired,
            startedAt: Date()
        )

        let offer = DuplicateTradeLogic.offer(
            activeCreature: active,
            currentStage: .adult,
            completedCreatures: [completedTinyRaptor()]
        )
        XCTAssertNil(offer)
    }

    func testOffer_notAdult_notEligible() {
        let offer = DuplicateTradeLogic.offer(
            activeCreature: adultTinyRaptor(steps: 4_000),
            currentStage: .juvenile,
            completedCreatures: [completedTinyRaptor()]
        )
        XCTAssertNil(offer)
    }

    func testOffer_legendarySpecies_notEligible() {
        let apex = CreatureCatalog.creature(withSpeciesId: "ancient_apex_rex")!
        let active = ActiveCreature(
            eggRarity: .legendary,
            definition: apex,
            currentSteps: apex.totalStepsRequired,
            startedAt: Date()
        )
        let completed = CompletedCreature(
            id: UUID(),
            definition: apex,
            totalStepsCompleted: apex.totalStepsRequired,
            completedAt: Date()
        )

        let offer = DuplicateTradeLogic.offer(
            activeCreature: active,
            currentStage: .adult,
            completedCreatures: [completed]
        )
        XCTAssertNil(offer)
    }

    func testNextEggRarity_tiers() {
        XCTAssertEqual(DuplicateTradeLogic.nextEggRarity(after: .common), .uncommon)
        XCTAssertEqual(DuplicateTradeLogic.nextEggRarity(after: .uncommon), .rare)
        XCTAssertEqual(DuplicateTradeLogic.nextEggRarity(after: .rare), .epic)
        XCTAssertEqual(DuplicateTradeLogic.nextEggRarity(after: .epic), .legendary)
        XCTAssertNil(DuplicateTradeLogic.nextEggRarity(after: .legendary))
    }

    func testRemoveOneCompleted_removesOldestMatchingSpecies() {
        var collection = [
            completedTinyRaptor(daysAgo: 5),
            completedTinyRaptor(daysAgo: 1),
        ]
        let other = CreatureCatalog.creature(withSpeciesId: "stegosaurus")!
        collection.append(
            CompletedCreature(
                id: UUID(),
                definition: other,
                totalStepsCompleted: other.totalStepsRequired,
                completedAt: Date()
            )
        )

        XCTAssertTrue(DuplicateTradeLogic.removeOneCompleted(speciesId: "tiny_raptor", from: &collection))
        XCTAssertEqual(DuplicateTradeLogic.collectionCount(speciesId: "tiny_raptor", in: collection), 1)
        XCTAssertEqual(collection.count, 2)
    }
}
