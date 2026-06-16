//
//  WatchComplicationCreatureVisual.swift
//  Dino Step Watch Widgets
//

import SwiftUI
import WidgetKit

/// Creature art for Infograph circular complications.
struct WatchComplicationCreatureVisual: View {
    let payload: WatchGameStatePayload?
    var visualSize: CGFloat

    private var placeholderEmoji: String {
        WatchCreatureVisualResolver.placeholderEmoji(for: payload)
    }

    var body: some View {
        Group {
            if WatchCreatureVisualResolver.isEggStage(payload),
               let rarity = payload?.rarity,
               let eggAsset = WatchCreatureVisualResolver.eggAssetName(for: rarity) {
                complicationImage(named: eggAsset)
            } else if let assetName = WatchCreatureVisualResolver.creatureAssetName(for: payload) {
                complicationImage(named: assetName)
            } else {
                Text(placeholderEmoji)
                    .font(.system(size: visualSize * 0.72))
            }
        }
        .frame(width: visualSize, height: visualSize)
    }

    @ViewBuilder
    private func complicationImage(named assetName: String) -> some View {
        Image(assetName, bundle: WatchCreatureAssetBundle.resourceBundle)
            .resizable()
            .scaledToFit()
    }
}
