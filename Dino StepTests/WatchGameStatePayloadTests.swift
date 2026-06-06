import XCTest
@testable import Dino_Step

final class WatchGameStatePayloadTests: XCTestCase {
    func testRoundTrip_applicationContext() throws {
        let payload = WatchGameStatePayload(
            displayName: "T-Rex",
            creatureName: "T-Rex",
            speciesId: "trex",
            stage: "BABY",
            rarity: "RARE",
            currentSteps: 12_000,
            nextMilestone: 25_000,
            totalStepsRequired: 50_000,
            progressPercent: 24,
            stageProgressPercent: 13.3,
            stepsUntilNextStage: 13_000,
            nextStageLabel: "juvenile",
            isRevealed: true,
            placeholderVisual: "🦖",
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let context = payload.applicationContext()
        let decoded = WatchGameStatePayload.decode(from: context)

        guard let decoded else {
            XCTFail("Expected decoded payload")
            return
        }
        XCTAssertEqual(decoded.speciesId, "trex")
        XCTAssertEqual(decoded.stage, "BABY")
        XCTAssertEqual(decoded.stepsUntilNextStage, 13_000)
        XCTAssertEqual(decoded.nextStageLabel, "juvenile")
        XCTAssertEqual(decoded.ringProgressPercent, 13.3, accuracy: 0.01)
    }

    func testDecodeLegacyPayload_withoutStageProgressFields() throws {
        struct LegacyPayload: Codable {
            let displayName: String
            let creatureName: String
            let stage: String
            let rarity: String
            let currentSteps: Int
            let nextMilestone: Int
            let totalStepsRequired: Int
            let progressPercent: Double
            let stepsUntilNextMilestone: Int
            let nextStageLabel: String
            let isRevealed: Bool
            let placeholderVisual: String
            let updatedAt: Date
        }

        let legacy = LegacyPayload(
            displayName: "Mystery Egg",
            creatureName: "Mystery",
            stage: "EGG",
            rarity: "COMMON",
            currentSteps: 100,
            nextMilestone: 1_600,
            totalStepsRequired: 8_000,
            progressPercent: 6.25,
            stepsUntilNextMilestone: 1_500,
            nextStageLabel: "hatch",
            isRevealed: false,
            placeholderVisual: "🥚",
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let data = try JSONEncoder().encode(legacy)
        let json = String(data: data, encoding: .utf8)!
        let decoded = WatchGameStatePayload.decode(from: [WatchGameStatePayload.contextKey: json])

        guard let decoded else {
            XCTFail("Expected legacy payload decode")
            return
        }
        XCTAssertNil(decoded.speciesId)
        XCTAssertEqual(decoded.stepsUntilNextStage, 1_500)
        XCTAssertEqual(decoded.stageProgressPercent, 6.25, accuracy: 0.01)
    }

    func testMilestoneText_adultReadyToClaim() {
        let payload = WatchGameStatePayload(
            displayName: "T-Rex",
            creatureName: "T-Rex",
            speciesId: "trex",
            stage: "ADULT",
            rarity: "RARE",
            currentSteps: 50_000,
            nextMilestone: 50_000,
            totalStepsRequired: 50_000,
            progressPercent: 100,
            stageProgressPercent: 100,
            stepsUntilNextStage: 0,
            nextStageLabel: "claim",
            isRevealed: true,
            placeholderVisual: "🦖",
            updatedAt: Date()
        )

        XCTAssertEqual(payload.milestoneText, "Ready to claim")
    }
}
