//
//  HealthKitStepSyncEngineTests.swift
//  Dino StepTests
//

import XCTest
@testable import Dino_Step

final class HealthKitStepSyncEngineTests: XCTestCase {
    func testResetBaselineOnNewDayClearsSyncedTotal() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        var activeCreature = ActiveCreature.newEgg(
            definition: CreatureCatalog.creatures(for: .common).first!,
            eggRarity: .common
        )
        activeCreature.currentSteps = 1200
        var snapshot = GameStateSnapshot(
            activeCreature: activeCreature,
            completedCreatures: [],
            lastRewardedEggRarity: nil,
            lastRewardRollPercent: nil,
            lastSyncedHealthKitStepTotal: 5000,
            lastHealthKitSyncDayStart: Calendar.current.startOfDay(for: yesterday),
            lastHealthKitSyncMessage: nil,
            lifetimeStepsApplied: 0,
            pendingRewardEggRarity: nil
        )

        HealthKitStepSyncBaseline.resetIfNeeded(snapshot: &snapshot)

        XCTAssertEqual(snapshot.lastSyncedHealthKitStepTotal, 0)
        XCTAssertEqual(
            snapshot.lastHealthKitSyncDayStart,
            Calendar.current.startOfDay(for: Date())
        )
    }

    func testResetBaselineSameDayPreservesSyncedTotal() {
        let todayStart = Calendar.current.startOfDay(for: Date())
        var activeCreature = ActiveCreature.newEgg(
            definition: CreatureCatalog.creatures(for: .common).first!,
            eggRarity: .common
        )
        activeCreature.currentSteps = 1200
        var snapshot = GameStateSnapshot(
            activeCreature: activeCreature,
            completedCreatures: [],
            lastRewardedEggRarity: nil,
            lastRewardRollPercent: nil,
            lastSyncedHealthKitStepTotal: 5000,
            lastHealthKitSyncDayStart: todayStart,
            lastHealthKitSyncMessage: nil,
            lifetimeStepsApplied: 0,
            pendingRewardEggRarity: nil
        )

        HealthKitStepSyncBaseline.resetIfNeeded(snapshot: &snapshot)

        XCTAssertEqual(snapshot.lastSyncedHealthKitStepTotal, 5000)
        XCTAssertEqual(snapshot.lastHealthKitSyncDayStart, todayStart)
    }
}
