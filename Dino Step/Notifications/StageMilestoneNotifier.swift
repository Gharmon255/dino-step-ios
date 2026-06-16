//
//  StageMilestoneNotifier.swift
//  Dino Step
//

import Foundation
import UserNotifications

#if os(iOS)
final class AppNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = AppNotificationCenterDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

enum StageMilestoneNotifier {
    private static let categoryIdentifier = "creature_progress"

    static func configure() {
        let center = UNUserNotificationCenter.current()
        center.delegate = AppNotificationCenterDelegate.shared
        requestAuthorizationIfNeeded()
    }

    static func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    static func notifyIfNeeded(previous: ActiveCreature, current: ActiveCreature) {
        guard let milestone = detectMilestone(previous: previous, current: current) else { return }

        let content = UNMutableNotificationContent()
        switch milestone {
        case .hatched:
            content.title = "Egg hatched!"
            content.body = "Meet \(current.definition.name)! Keep walking to help them grow."
        case .grewToJuvenile:
            content.title = "\(current.definition.name) is growing up!"
            content.body = "Your dino reached the juvenile stage."
        case .grewToAdult:
            content.title = "Fully grown!"
            content.body = "\(current.definition.name) is ready. Open Stepasaurus to claim your reward egg."
        }
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier

        let identifier = "stage-\(milestone.rawValue)-\(current.definition.speciesId)-\(current.currentSteps)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )

        deliver(request)
    }

    private static func deliver(_ request: UNNotificationRequest) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    guard granted else { return }
                    center.add(request)
                }
            case .authorized, .provisional, .ephemeral:
                center.add(request) { error in
                    if let error {
                        print("[StageMilestoneNotifier] Failed to deliver: \(error.localizedDescription)")
                    }
                }
            case .denied:
                print("[StageMilestoneNotifier] Notifications denied in Settings")
            @unknown default:
                break
            }
        }
    }

    private enum Milestone: String {
        case hatched
        case grewToJuvenile
        case grewToAdult
    }

    private static func detectMilestone(previous: ActiveCreature, current: ActiveCreature) -> Milestone? {
        let previousStage = GameLogic.calculateStage(
            currentSteps: previous.currentSteps,
            creatureDefinition: previous.definition
        )
        let currentStage = GameLogic.calculateStage(
            currentSteps: current.currentSteps,
            creatureDefinition: current.definition
        )

        if previousStage == .egg && currentStage != .egg {
            return .hatched
        }
        if previousStage == currentStage {
            return nil
        }
        switch currentStage {
        case .juvenile:
            return .grewToJuvenile
        case .adult:
            return .grewToAdult
        default:
            return nil
        }
    }
}
#endif
