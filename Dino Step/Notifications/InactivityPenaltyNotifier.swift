//
//  InactivityPenaltyNotifier.swift
//  Dino Step
//

import Foundation
import UserNotifications

#if os(iOS)
enum InactivityPenaltyNotifier {
    private static let categoryIdentifier = "activity_penalty"

    static func notify(yesterdaySteps: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Your dino needs more steps!"
        content.body =
            "You walked \(yesterdaySteps.formatted()) steps yesterday. Walk at least " +
            "\(DailyActivityPenalty.minimumDailySteps.formatted()) steps a day to keep growing. " +
            "Your dino is back in an egg with \(DailyActivityPenalty.penaltyRemainingSteps) steps of progress."
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier

        let request = UNNotificationRequest(
            identifier: "activity_penalty_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
#endif
