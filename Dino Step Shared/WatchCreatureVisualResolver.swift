//
//  WatchCreatureVisualResolver.swift
//  Dino Step Shared
//

import Foundation

enum WatchCreatureVisualResolver {
    static func isEggStage(_ payload: WatchGameStatePayload?) -> Bool {
        payload?.stage == "EGG"
    }

    static func placeholderEmoji(for payload: WatchGameStatePayload?) -> String {
        guard let payload else { return "🥚" }
        let trimmed = payload.placeholderVisual.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "🦖" : trimmed
    }

    static func eggAssetName(for rarity: String) -> String? {
        guard RarityEggVisual.shouldUseAssetImage(for: rarity) else { return nil }
        return RarityEggVisual.assetName(for: rarity)
    }

    static func creatureAssetName(for payload: WatchGameStatePayload?) -> String? {
        guard let payload, !isEggStage(payload) else { return nil }

        let speciesKey: String? = {
            if let resolved = payload.resolvedSpeciesIdForAssets, !resolved.isEmpty {
                return resolved
            }
            if let speciesId = payload.speciesId, !speciesId.isEmpty {
                return speciesId
            }
            if !payload.creatureName.isEmpty {
                return payload.creatureName
            }
            return nil
        }()

        guard let speciesKey else { return nil }
        return CreatureAssetVisual.assetName(forSpeciesId: speciesKey, stage: payload.stage)
    }
}
