import XCTest
@testable import Dino_Step

final class GameLogicTests: XCTestCase {
    private let v2Rare = CreatureEconomy.catalogThresholds(for: .rare)
    private let legacyTrex = CreatureEconomy.legacyV1Thresholds(for: "trex")

    func testCalculateStage_v2Progression() {
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 0, progression: v2Rare), .egg)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: v2Rare.hatchStep - 1, progression: v2Rare), .egg)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: v2Rare.hatchStep, progression: v2Rare), .baby)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: v2Rare.juvenileStep, progression: v2Rare), .juvenile)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: v2Rare.totalStepsRequired, progression: v2Rare), .adult)
    }

    func testCalculateStage_legacyV1Snapshot() {
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 0, progression: legacyTrex), .egg)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 9_999, progression: legacyTrex), .egg)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 10_000, progression: legacyTrex), .baby)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 25_000, progression: legacyTrex), .juvenile)
        XCTAssertEqual(GameLogic.calculateStage(currentSteps: 50_000, progression: legacyTrex), .adult)
    }

    func testNextMilestone_v2Progression() {
        XCTAssertEqual(GameLogic.nextMilestone(currentSteps: 0, progression: v2Rare), v2Rare.hatchStep)
        XCTAssertEqual(GameLogic.nextMilestone(currentSteps: v2Rare.hatchStep, progression: v2Rare), v2Rare.juvenileStep)
        XCTAssertEqual(GameLogic.nextMilestone(currentSteps: v2Rare.juvenileStep, progression: v2Rare), v2Rare.totalStepsRequired)
        XCTAssertNil(GameLogic.nextMilestone(currentSteps: v2Rare.totalStepsRequired, progression: v2Rare))
    }

    func testStageProgressPercent_withinCurrentStage() {
        XCTAssertEqual(
            GameLogic.stageProgressPercent(currentSteps: legacyTrex.hatchStep / 2, progression: legacyTrex),
            50.0,
            accuracy: 0.01
        )
        XCTAssertEqual(
            GameLogic.stageProgressPercent(currentSteps: legacyTrex.hatchStep, progression: legacyTrex),
            0.0,
            accuracy: 0.01
        )
        let midJuvenile = legacyTrex.hatchStep + (legacyTrex.juvenileStep - legacyTrex.hatchStep) / 2
        XCTAssertEqual(
            GameLogic.stageProgressPercent(currentSteps: midJuvenile, progression: legacyTrex),
            50.0,
            accuracy: 0.01
        )
        XCTAssertEqual(
            GameLogic.stageProgressPercent(currentSteps: legacyTrex.totalStepsRequired, progression: legacyTrex),
            100.0,
            accuracy: 0.01
        )
    }

    func testNextStageLabel() {
        XCTAssertEqual(GameLogic.nextStageLabel(for: .egg), "hatch")
        XCTAssertEqual(GameLogic.nextStageLabel(for: .adult), "claim")
    }
}
