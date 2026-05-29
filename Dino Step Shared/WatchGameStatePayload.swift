//
//  WatchGameStatePayload.swift
//  Dino Step Shared
//

import Foundation

struct WatchGameStatePayload: Codable, Equatable {
    static let contextKey = "watchGameStatePayload"

    let displayName: String
    let creatureName: String
    let stage: String
    let rarity: String
    let currentSteps: Int
    let nextMilestone: Int
    let totalStepsRequired: Int
    let progressPercent: Double
    let stageProgressPercent: Double
    let stepsUntilNextStage: Int
    let nextStageLabel: String
    let isRevealed: Bool
    let placeholderVisual: String
    let updatedAt: Date

    var ringProgressPercent: Double {
        min(100.0, max(0.0, stageProgressPercent))
    }

    var milestoneText: String {
        if stage == "ADULT" {
            return "Ready to claim"
        }
        return "\(stepsUntilNextStage.formatted()) to \(nextStageLabel)"
    }
}

extension WatchGameStatePayload {
    func applicationContext() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8) else {
            return [:]
        }
        return [Self.contextKey: json]
    }

    static func decode(from context: [String: Any]) -> WatchGameStatePayload? {
        guard let json = context[contextKey] as? String,
              let data = json.data(using: .utf8) else {
            return nil
        }

        if let payload = try? JSONDecoder().decode(WatchGameStatePayload.self, from: data) {
            return payload
        }

        return decodeLegacyPayload(from: data)
    }

    /// Supports payloads saved before stage-progress fields were added.
    private static func decodeLegacyPayload(from data: Data) -> WatchGameStatePayload? {
        struct LegacyPayload: Codable {
            let displayName: String
            let creatureName: String
            let stage: String
            let rarity: String
            let currentSteps: Int
            let nextMilestone: Int
            let totalStepsRequired: Int
            let progressPercent: Double
            let stepsUntilNextMilestone: Int?
            let nextStageLabel: String
            let isRevealed: Bool
            let placeholderVisual: String
            let updatedAt: Date
        }

        guard let legacy = try? JSONDecoder().decode(LegacyPayload.self, from: data) else {
            return nil
        }

        return WatchGameStatePayload(
            displayName: legacy.displayName,
            creatureName: legacy.creatureName,
            stage: legacy.stage,
            rarity: legacy.rarity,
            currentSteps: legacy.currentSteps,
            nextMilestone: legacy.nextMilestone,
            totalStepsRequired: legacy.totalStepsRequired,
            progressPercent: legacy.progressPercent,
            stageProgressPercent: legacy.progressPercent,
            stepsUntilNextStage: legacy.stepsUntilNextMilestone ?? 0,
            nextStageLabel: legacy.nextStageLabel,
            isRevealed: legacy.isRevealed,
            placeholderVisual: legacy.placeholderVisual,
            updatedAt: legacy.updatedAt
        )
    }
}
