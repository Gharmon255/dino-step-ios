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
    let stepsUntilNextMilestone: Int
    let nextStageLabel: String
    let isRevealed: Bool
    let placeholderVisual: String
    let updatedAt: Date

    var milestoneText: String {
        if stage == "ADULT" {
            return "Fully grown"
        }
        return "\(stepsUntilNextMilestone.formatted()) to \(nextStageLabel)"
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
        return try? JSONDecoder().decode(WatchGameStatePayload.self, from: data)
    }
}
