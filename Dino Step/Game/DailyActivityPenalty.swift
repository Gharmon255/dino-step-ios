//
//  DailyActivityPenalty.swift
//  Dino Step
//

import Foundation

struct DailyActivityPenaltyResult {
    let creature: ActiveCreature
    let yesterdaySteps: Int
}

enum DailyActivityPenalty {
    static let minimumDailySteps = 5_000
    static let penaltyRemainingSteps = 500

    static func applyIfNeeded(
        yesterdaySteps: Int,
        activeCreature: ActiveCreature
    ) -> DailyActivityPenaltyResult? {
        guard yesterdaySteps < minimumDailySteps else { return nil }
        guard GameLogic.isHatched(activeCreature) || activeCreature.currentSteps > penaltyRemainingSteps else {
            return nil
        }

        var resetCreature = activeCreature
        resetCreature.currentSteps = penaltyRemainingSteps
        return DailyActivityPenaltyResult(
            creature: resetCreature,
            yesterdaySteps: yesterdaySteps
        )
    }
}
