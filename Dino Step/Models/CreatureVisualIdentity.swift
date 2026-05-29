//
//  CreatureVisualIdentity.swift
//  Dino Step
//

import SwiftUI

struct CreatureVisualIdentity: Equatable {
    let creatureId: UUID
    let shortCode: String
    let baseEmoji: String
    let primaryColor: Color
    let secondaryColor: Color
    let silhouetteLabel: String
    let eggAssetKey: String
    let babyAssetKey: String
    let juvenileAssetKey: String
    let adultAssetKey: String
}

struct StageVisual: Equatable {
    let displayEmoji: String
    let label: String
    let size: CGFloat
    let emojiFontSize: CGFloat
    let labelFontSize: CGFloat
    let stageDescription: String
    let accentColor: Color
    let secondaryColor: Color
}
