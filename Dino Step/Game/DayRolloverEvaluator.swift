//
//  DayRolloverEvaluator.swift
//  Dino Step
//

import Foundation

struct DayRolloverOutcome {
    let activeCreature: ActiveCreature
    let penalty: DailyActivityPenaltyResult?
}

enum DayRolloverEvaluator {
    static func evaluateIfNeeded(
        activeCreature: ActiveCreature,
        lastSyncedHealthKitStepTotal: Int,
        lastHealthKitSyncDayStart: Date?,
        fetchYesterdaySteps: () async throws -> Int
    ) async -> DayRolloverOutcome {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let lastEvaluatedDay = AppExperienceStore.lastActivityEvaluationDayStart

        if let lastEvaluatedDay, lastEvaluatedDay >= todayStart {
            return DayRolloverOutcome(activeCreature: activeCreature, penalty: nil)
        }

        var creature = activeCreature
        var penalty: DailyActivityPenaltyResult?

        if let lastEvaluatedDay {
            let yesterdaySteps = await resolveYesterdaySteps(
                lastSyncedHealthKitStepTotal: lastSyncedHealthKitStepTotal,
                lastHealthKitSyncDayStart: lastHealthKitSyncDayStart,
                fetchYesterdaySteps: fetchYesterdaySteps
            )
            if let result = DailyActivityPenalty.applyIfNeeded(
                yesterdaySteps: yesterdaySteps,
                activeCreature: creature
            ) {
                creature = result.creature
                penalty = result
            }
        }

        AppExperienceStore.setLastActivityEvaluationDayStart(todayStart)
        return DayRolloverOutcome(activeCreature: creature, penalty: penalty)
    }

    private static func resolveYesterdaySteps(
        lastSyncedHealthKitStepTotal: Int,
        lastHealthKitSyncDayStart: Date?,
        fetchYesterdaySteps: () async throws -> Int
    ) async -> Int {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        guard let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart) else {
            return 0
        }

        if lastHealthKitSyncDayStart == yesterdayStart {
            return lastSyncedHealthKitStepTotal
        }

        return (try? await fetchYesterdaySteps()) ?? 0
    }
}
