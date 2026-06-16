//
//  WatchCreatureAssetBundle.swift
//  Dino Step Shared
//

import Foundation

enum WatchCreatureAssetBundle {
    /// Bundle that contains `Assets.car` for watch creature PNGs.
    static var resourceBundle: Bundle {
#if os(watchOS)
        if isWidgetExtension,
           let watchAppBundle = hostingWatchAppBundle {
            return watchAppBundle
        }
#endif
        return .main
    }

    private static var isWidgetExtension: Bool {
        Bundle.main.bundlePath.hasSuffix(".appex")
    }

    private static var hostingWatchAppBundle: Bundle? {
        let watchAppURL = Bundle.main.bundleURL
            .deletingLastPathComponent() // PlugIns
            .deletingLastPathComponent() // *.app
        return Bundle(url: watchAppURL)
    }
}
