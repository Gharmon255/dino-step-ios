//
//  CloudSaveMapperTests.swift
//  Dino StepTests
//

import XCTest
@testable import Dino_Step

final class CloudSaveMapperTests: XCTestCase {
    func testRoundTripPreservesSpecies() throws {
        guard let definition = CreatureCatalog.creature(withSpeciesId: "tiny_raptor") else {
            XCTFail("Missing species")
            return
        }

        let snapshot = GameStateSnapshot(
            activeCreature: ActiveCreature(
                eggRarity: .common,
                definition: definition,
                progression: CreatureEconomy.thresholds(for: definition),
                currentSteps: 42,
                startedAt: Date(timeIntervalSince1970: 1_700_000_000),
                nickname: "Spike"
            ),
            completedCreatures: [],
            lastRewardedEggRarity: nil,
            lastRewardRollPercent: nil,
            lastSyncedHealthKitStepTotal: 100,
            lastHealthKitSyncDayStart: Date(timeIntervalSince1970: 1_700_000_000),
            lastHealthKitSyncMessage: nil,
            lifetimeStepsApplied: 9000,
            pendingRewardEggRarity: .epic
        )

        let cloud = CloudSaveMapper.toCloud(
            snapshot: snapshot,
            revision: 3,
            updatedAt: "2026-06-18T12:00:00Z"
        )
        XCTAssertEqual(cloud.activeCreature.speciesId, "tiny_raptor")

        let restored = CloudSaveMapper.toSnapshot(cloud)
        XCTAssertEqual(restored?.activeCreature.definition.speciesId, "tiny_raptor")
        XCTAssertEqual(restored?.activeCreature.currentSteps, 42)
        XCTAssertEqual(restored?.lifetimeStepsApplied, 9000)
        XCTAssertEqual(restored?.pendingRewardEggRarity, .epic)
    }

    func testIsLocalEmptyForFreshInstall() {
        guard let definition = CreatureCatalog.creature(withSpeciesId: "tiny_raptor") else {
            XCTFail("Missing species")
            return
        }
        let snapshot = GameStateSnapshot(
            activeCreature: ActiveCreature(
                eggRarity: .common,
                definition: definition,
                progression: CreatureEconomy.thresholds(for: definition),
                currentSteps: 0,
                startedAt: Date(),
                nickname: nil
            ),
            completedCreatures: [],
            lastRewardedEggRarity: nil,
            lastRewardRollPercent: nil,
            lastSyncedHealthKitStepTotal: 0,
            lastHealthKitSyncDayStart: nil,
            lastHealthKitSyncMessage: nil,
            lifetimeStepsApplied: 0,
            pendingRewardEggRarity: nil
        )
        XCTAssertTrue(CloudSaveMapper.isLocalEmpty(snapshot))
    }
}
