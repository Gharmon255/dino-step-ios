//
//  WatchCreatureCenterVisual.swift
//  Dino Step Shared
//

import SwiftUI

/// Center creature/egg art for the watch app progress ring.
struct WatchCreatureCenterVisual: View {
    let payload: WatchGameStatePayload?
    var visualSize: CGFloat

    private var assetBundle: Bundle {
        WatchCreatureAssetBundle.resourceBundle
    }

    private var placeholderEmoji: String {
        WatchCreatureVisualResolver.placeholderEmoji(for: payload)
    }

    var body: some View {
        if WatchCreatureVisualResolver.isEggStage(payload),
           let rarity = payload?.rarity,
           let eggAsset = WatchCreatureVisualResolver.eggAssetName(for: rarity) {
            Image(eggAsset, bundle: assetBundle)
                .resizable()
                .scaledToFit()
                .frame(width: visualSize, height: visualSize)
        } else if let assetName = WatchCreatureVisualResolver.creatureAssetName(for: payload) {
            Image(assetName, bundle: assetBundle)
                .resizable()
                .scaledToFit()
                .frame(width: visualSize, height: visualSize)
        } else {
            Text(placeholderEmoji)
                .font(.system(size: visualSize * 0.72))
        }
    }
}
