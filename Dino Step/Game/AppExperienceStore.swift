//
//  AppExperienceStore.swift
//  Dino Step
//

import Foundation

enum AppExperienceStore {
    static let currentWhatsNewVersion = 1

    private static let onboardingCompleteKey = "app_experience.onboarding_complete"
    private static let whatsNewVersionKey = "app_experience.whats_new_version"
    private static let lastActivityEvaluationDayKey = "app_experience.last_activity_eval_day"
    private static let battleIntroDismissedKey = "app_experience.battle_intro_dismissed"

    static var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: onboardingCompleteKey)
    }

    static func setOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: onboardingCompleteKey)
    }

    static var lastSeenWhatsNewVersion: Int {
        UserDefaults.standard.integer(forKey: whatsNewVersionKey)
    }

    static func setLastSeenWhatsNewVersion(_ version: Int) {
        UserDefaults.standard.set(version, forKey: whatsNewVersionKey)
    }

    static var lastActivityEvaluationDayStart: Date? {
        UserDefaults.standard.object(forKey: lastActivityEvaluationDayKey) as? Date
    }

    static func setLastActivityEvaluationDayStart(_ date: Date) {
        UserDefaults.standard.set(date, forKey: lastActivityEvaluationDayKey)
    }

    static var hasDismissedBattleIntroPermanently: Bool {
        UserDefaults.standard.bool(forKey: battleIntroDismissedKey)
    }

    static func setBattleIntroDismissedPermanently() {
        UserDefaults.standard.set(true, forKey: battleIntroDismissedKey)
    }
}
