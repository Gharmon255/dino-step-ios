//
//  ProgressionThresholds.swift
//  Dino Step
//

import Foundation

struct ProgressionThresholds: Equatable, Codable {
    let hatchStep: Int
    let juvenileStep: Int
    let totalStepsRequired: Int
    let economyVersion: Int

    func stage(for steps: Int) -> GrowthStage {
        if steps >= totalStepsRequired { return .adult }
        if steps >= juvenileStep { return .juvenile }
        if steps >= hatchStep { return .baby }
        return .egg
    }

    func nextMilestone(for steps: Int) -> Int? {
        switch stage(for: steps) {
        case .egg: return hatchStep
        case .baby: return juvenileStep
        case .juvenile: return totalStepsRequired
        case .adult: return nil
        }
    }

    func overallProgressPercent(for steps: Int) -> Double {
        guard totalStepsRequired > 0 else { return 0 }
        return min(100, Double(max(0, steps)) / Double(totalStepsRequired) * 100)
    }

    func stageProgressPercent(for steps: Int) -> Double {
        switch stage(for: steps) {
        case .egg:
            guard hatchStep > 0 else { return 0 }
            return min(100, Double(max(0, steps)) / Double(hatchStep) * 100)
        case .baby:
            let range = juvenileStep - hatchStep
            guard range > 0 else { return 100 }
            return min(100, Double(max(0, steps - hatchStep)) / Double(range) * 100)
        case .juvenile:
            let range = totalStepsRequired - juvenileStep
            guard range > 0 else { return 100 }
            return min(100, Double(max(0, steps - juvenileStep)) / Double(range) * 100)
        case .adult:
            return 100
        }
    }
}
