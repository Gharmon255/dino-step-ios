//
//  WatchGameStatePayload.swift
//  Dino Step Shared
//

import Foundation

/// JSON payload sent from iPhone to Apple Watch via WatchConnectivity application context.
/// See `WATCH_SYNC_CONTRACT.md` for field meanings and compatibility rules.
struct WatchGameStatePayload: Codable, Equatable {
    static let contextKey = "watchGameStatePayload"

    let displayName: String
    let creatureName: String
    /// Canonical species slug (e.g. `trex`, `pteranodon`). Optional for backward compatibility with older payloads.
    let speciesId: String?
    let stage: String
    let rarity: String
    let currentSteps: Int
    let nextMilestone: Int
    let totalStepsRequired: Int
    /// Lifetime progress toward fully grown (0–100). Not used for the watch ring.
    let progressPercent: Double
    /// Progress within the current growth stage toward the next stage (0–100). Drives the watch ring.
    let stageProgressPercent: Double
    let stepsUntilNextStage: Int
    let nextStageLabel: String
    let isRevealed: Bool
    let placeholderVisual: String
    let updatedAt: Date

    /// Progress shown on the watch ring: current stage → next stage, not total lifetime progress.
    var ringProgressPercent: Double {
        min(100.0, max(0.0, stageProgressPercent))
    }

    var milestoneText: String {
        if stage == "ADULT" {
            return "Ready to claim"
        }
        return "\(stepsUntilNextStage.formatted()) to \(nextStageLabel)"
    }

    /// Species key for asset lookup: prefers `speciesId`, falls back to normalizing `creatureName`.
    var resolvedSpeciesIdForAssets: String? {
        if let speciesId, !speciesId.isEmpty {
            return CreatureAssetVisual.normalizedSpeciesId(from: speciesId) ?? speciesId
        }
        return CreatureAssetVisual.normalizedSpeciesId(from: creatureName)
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
            speciesId: nil,
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
