//
//  WatchComplicationTimelineRefresher.swift
//  Dino Step Shared
//

import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

enum WatchComplicationTimelineRefresher {
    static let widgetKinds = [
        "StepasaurusCreature",
        "StepasaurusSteps",
        "StepasaurusProgress",
        "StepasaurusStage",
        "StepasaurusMilestone",
    ]

    static func reloadAll() {
#if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        for kind in widgetKinds {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
        }
#endif
    }
}
