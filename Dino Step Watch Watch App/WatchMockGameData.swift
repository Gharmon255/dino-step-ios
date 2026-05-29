//
//  WatchMockGameData.swift
//  Dino Step Watch Watch App
//

import Foundation

enum WatchRarity: String {
    case common = "COMMON"
    case uncommon = "UNCOMMON"
    case rare = "RARE"
    case epic = "EPIC"
    case legendary = "LEGENDARY"
}

struct WatchMockGameData {
    let syncStatus: String
    let displayName: String
    let stage: String
    let progressPercent: Double
    let stepsUntilNextMilestone: Int
    let nextStageLabel: String
    let rarity: WatchRarity

    static let sample = WatchMockGameData(
        syncStatus: "Sample",
        displayName: "Mystery Common Egg",
        stage: "EGG",
        progressPercent: 25,
        stepsUntilNextMilestone: 1500,
        nextStageLabel: "hatch",
        rarity: .common
    )

    var milestoneText: String {
        "\(stepsUntilNextMilestone.formatted()) to \(nextStageLabel)"
    }
}
