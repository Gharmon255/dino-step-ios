import XCTest
@testable import Dino_Step

final class GameLogicTests: XCTestCase {
    private let trex = CreatureDefinition(
        id: UUID(uuidString: "A1000013-0000-4000-8000-000000000013")!,
        speciesId: "trex",
        name: "T-Rex",
        rarity: .rare,
        habitat: .volcano,
        totalStepsRequired: 50_000,
        hatchStep: 10_000,
        juvenileStep: 25_000
    )

    func testCalculateStage_progression() {
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 0, creatureDefinition: trex), .egg)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 9_999, creatureDefinition: trex), .egg)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 10_000, creatureDefinition: trex), .baby)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 25_000, creatureDefinition: trex), .juvenile)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 50_000, creatureDefinition: trex), .adult)
    }

    func testNextMilestone_perStage() {
        XCTAssertEqual(GameLogic.nextMilestone(currentSteps: 0, creatureDefinition: trex), 10_000)
        XCTAssertEqual(GameLogic.nextMilestone(currentSteps: 10_000, creatureDefinition: trex), 25_000)
        XCTAssertEqual(GameLogic.nextMilestone(currentSteps: 25_000, creatureDefinition: trex), 50_000)
        XCTAssertNil(GameLogic.nextMilestone(currentSteps: 50_000, creatureDefinition: trex))
    }

    func testStageProgressPercent_withinCurrentStage() {
        XCTAssertEqual(GameLogic.stageProgressPercent(currentSteps: 5_000, creatureDefinition: trex), 50.0, accuracy: 0.01)
        XCTAssertEqual(GameLogic.stageProgressPercent(currentSteps: 10_000, creatureDefinition: trex), 0.0, accuracy: 0.01)
        XCTAssertEqual(GameLogic.stageProgressPercent(currentSteps: 17_500, creatureDefinition: trex), 50.0, accuracy: 0.01)
        XCTAssertEqual(GameLogic.stageProgressPercent(currentSteps: 50_000, creatureDefinition: trex), 100.0, accuracy: 0.01)
    }

    func testNextStageLabel() {
        XCTAssertEqual(GameLogic.nextStageLabel(for: .egg), "hatch")
        XCTAssertEqual(GameLogic.nextStageLabel(for: .adult), "claim")
    }
}
