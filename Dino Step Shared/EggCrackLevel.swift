//
//  EggCrackLevel.swift
//  Dino Step Shared
//

import Foundation

enum EggCrackLevel {
    static func from(progress: Double) -> Int {
        switch progress {
        case 0.85...: return 3
        case 0.55...: return 2
        case 0.25...: return 1
        default: return 0
        }
    }

    static func forEgg(currentSteps: Int, hatchStep: Int) -> Int {
        guard hatchStep > 0 else { return 0 }
        let progress = Double(max(0, currentSteps)) / Double(hatchStep)
        return from(progress: progress)
    }
}
