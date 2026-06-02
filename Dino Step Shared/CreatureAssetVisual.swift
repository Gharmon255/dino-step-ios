//
//  CreatureAssetVisual.swift
//  Dino Step Shared
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum CreatureAssetVisual {
    static let assetBackedSpeciesIds: Set<String> = [
        "tiny_raptor",
        "triceratops",
        "trex",
        "stegosaurus",
        "brachiosaurus",
        "ankylosaurus",
        "parasaurolophus",
        "spinosaurus",
        "pteranodon",
        "dilophosaurus",
        "carnotaurus",
        "mosasaurus",
        "pachycephalosaurus",
        "allosaurus",
        "iguanodon",
        "gallimimus",
        "baryonyx",
        "velociraptor_alpha",
        "therizinosaurus",
        "giganotosaurus",
    ]

    /// Legacy display names, slugs, and alternate spellings mapped to canonical species IDs.
    private static let speciesIdAliases: [String: String] = [
        "pterodactyl": "pteranodon",
        "t_rex": "trex",
        "t-rex": "trex",
        "tyrannosaurus": "trex",
        "tyrannosaurus_rex": "trex",
    ]

    /// Resolves a canonical species ID when the input is asset-backed; otherwise nil.
    static func normalizedSpeciesId(from input: String) -> String? {
        let slug = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")

        let resolved = speciesIdAliases[slug] ?? slug
        guard assetBackedSpeciesIds.contains(resolved) else { return nil }
        return resolved
    }

    static func assetName(forSpeciesId speciesId: String, stage: String) -> String? {
        guard let resolved = normalizedSpeciesId(from: speciesId),
              let stageSuffix = normalizedStageSuffix(from: stage) else {
            return nil
        }
        return "dino_\(resolved)_\(stageSuffix)"
    }

    /// Accepts a canonical species ID or legacy display name/slug.
    static func assetName(for speciesOrName: String, stage: String) -> String? {
        assetName(forSpeciesId: speciesOrName, stage: stage)
    }

    static func assetIsAvailable(named name: String) -> Bool {
#if canImport(UIKit)
        UIImage(named: name) != nil
#else
        false
#endif
    }

    static func shouldUseAssetImage(forSpeciesId speciesId: String, stage: String) -> Bool {
#if os(iOS) || os(watchOS)
        guard let assetName = assetName(forSpeciesId: speciesId, stage: stage) else { return false }
        let available = assetIsAvailable(named: assetName)
        #if DEBUG
        if !available {
            print("[CreatureAssetVisual] Missing asset: \(assetName)")
        }
        #endif
        return available
#else
        false
#endif
    }

    /// Accepts a canonical species ID or legacy display name/slug.
    static func shouldUseAssetImage(for speciesOrName: String, stage: String) -> Bool {
        shouldUseAssetImage(forSpeciesId: speciesOrName, stage: stage)
    }

    private static func normalizedStageSuffix(from stage: String) -> String? {
        switch stage.uppercased() {
        case "BABY": return "baby"
        case "JUVENILE": return "juvenile"
        case "ADULT": return "adult"
        default: return nil
        }
    }
}
