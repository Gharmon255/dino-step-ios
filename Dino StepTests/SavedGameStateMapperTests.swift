//
//  SavedGameStateMapperTests.swift
//  Dino StepTests
//

import XCTest
@testable import Dino_Step

final class SavedGameStateMapperTests: XCTestCase {
    func testSchemaVersion3SaveRestoresAfterTestFlightStyleUpdate() {
        let definition = CreatureCatalog.creature(withSpeciesId: "tiny_raptor")!
        let saved = SavedGameState(
            schemaVersion: 3,
            activeCreature: SavedActiveCreatureState(
                creatureDefinitionId: definition.id,
                eggRarity: Rarity.common.rawValue,
                currentSteps: 1200,
                startedAt: Date(timeIntervalSince1970: 1_700_000_000),
                hatchStep: 500,
                juvenileStep: 2500,
                totalStepsRequired: 5000,
                economyVersion: 2,
                nickname: nil
            ),
            completedCreatures: [
                SavedCompletedCreatureState(
                    id: UUID(),
                    creatureDefinitionId: definition.id,
                    totalStepsCompleted: 5000,
                    completedAt: Date(timeIntervalSince1970: 1_700_100_000),
                    nickname: "Rexy"
                ),
            ],
            lastRewardedEggRarity: Rarity.common.rawValue,
            lastRewardRollPercent: 42.0,
            lastSyncedHealthKitStepTotal: 800,
            lastHealthKitSyncDayStart: Date(),
            lastHealthKitSyncMessage: nil,
            lifetimeStepsApplied: 6200
        )

        let restored = SavedGameStateMapper.restore(from: saved)

        XCTAssertNotNil(restored)
        XCTAssertEqual(restored?.completedCreatures.count, 1)
        XCTAssertEqual(restored?.completedCreatures.first?.nickname, "Rexy")
        XCTAssertEqual(restored?.activeCreature.currentSteps, 1200)
        XCTAssertEqual(restored?.lifetimeStepsApplied, 6200)
    }

    func testUnsupportedSchemaVersionReturnsNil() {
        let definition = CreatureCatalog.creature(withSpeciesId: "tiny_raptor")!
        let saved = SavedGameState(
            schemaVersion: 99,
            activeCreature: SavedActiveCreatureState(
                creatureDefinitionId: definition.id,
                eggRarity: Rarity.common.rawValue,
                currentSteps: 0,
                startedAt: Date(),
                hatchStep: nil,
                juvenileStep: nil,
                totalStepsRequired: nil,
                economyVersion: nil,
                nickname: nil
            ),
            completedCreatures: [],
            lastRewardedEggRarity: nil,
            lastRewardRollPercent: nil,
            lastSyncedHealthKitStepTotal: nil,
            lastHealthKitSyncDayStart: nil,
            lastHealthKitSyncMessage: nil,
            lifetimeStepsApplied: nil
        )

        XCTAssertNil(SavedGameStateMapper.restore(from: saved))
    }
}
