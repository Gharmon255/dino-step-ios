//
//  CreatureAssetVisual.swift
//  Dino Step Shared
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum CreatureAssetVisual {
    static func assetName(for creatureName: String, stage: String) -> String? {
        switch creatureName {
        case "Tiny Raptor":
            switch stage.uppercased() {
            case "BABY": return "dino_tiny_raptor_baby"
            case "JUVENILE": return "dino_tiny_raptor_juvenile"
            case "ADULT": return "dino_tiny_raptor_adult"
            default: return nil
            }
        default:
            return nil
        }
    }

    static func assetIsAvailable(named name: String) -> Bool {
#if canImport(UIKit)
        UIImage(named: name) != nil
#else
        false
#endif
    }

    static func shouldUseAssetImage(for creatureName: String, stage: String) -> Bool {
#if os(iOS) || os(watchOS)
        guard let assetName = assetName(for: creatureName, stage: stage) else { return false }
        return assetIsAvailable(named: assetName)
#else
        false
#endif
    }
}
