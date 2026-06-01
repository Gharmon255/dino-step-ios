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
        case "Triceratops":
            switch stage.uppercased() {
            case "BABY": return "dino_triceratops_baby"
            case "JUVENILE": return "dino_triceratops_juvenile"
            case "ADULT": return "dino_triceratops_adult"
            default: return nil
            }
        case "T-Rex":
            switch stage.uppercased() {
            case "BABY": return "dino_trex_baby"
            case "JUVENILE": return "dino_trex_juvenile"
            case "ADULT": return "dino_trex_adult"
            default: return nil
            }
        case "Stegosaurus":
            switch stage.uppercased() {
            case "BABY": return "dino_stegosaurus_baby"
            case "JUVENILE": return "dino_stegosaurus_juvenile"
            case "ADULT": return "dino_stegosaurus_adult"
            default: return nil
            }
        case "Brachiosaurus":
            switch stage.uppercased() {
            case "BABY": return "dino_brachiosaurus_baby"
            case "JUVENILE": return "dino_brachiosaurus_juvenile"
            case "ADULT": return "dino_brachiosaurus_adult"
            default: return nil
            }
        case "Ankylosaurus":
            switch stage.uppercased() {
            case "BABY": return "dino_ankylosaurus_baby"
            case "JUVENILE": return "dino_ankylosaurus_juvenile"
            case "ADULT": return "dino_ankylosaurus_adult"
            default: return nil
            }
        case "Parasaurolophus":
            switch stage.uppercased() {
            case "BABY": return "dino_parasaurolophus_baby"
            case "JUVENILE": return "dino_parasaurolophus_juvenile"
            case "ADULT": return "dino_parasaurolophus_adult"
            default: return nil
            }
        case "Spinosaurus":
            switch stage.uppercased() {
            case "BABY": return "dino_spinosaurus_baby"
            case "JUVENILE": return "dino_spinosaurus_juvenile"
            case "ADULT": return "dino_spinosaurus_adult"
            default: return nil
            }
        case "Pterodactyl", "Pteranodon":
            switch stage.uppercased() {
            case "BABY": return "dino_pteranodon_baby"
            case "JUVENILE": return "dino_pteranodon_juvenile"
            case "ADULT": return "dino_pteranodon_adult"
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
}
