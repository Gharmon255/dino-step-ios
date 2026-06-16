//
//  StepasaurusWatchWidgets.swift
//  Dino Step Watch Widgets
//

import SwiftUI
import WidgetKit

private struct StepasaurusCreatureWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WatchComplicationEntry

    var body: some View {
        WatchCreatureCenterComplicationView(entry: entry)
    }
}

private struct StepasaurusStepsWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WatchComplicationEntry

    var body: some View {
        WatchCornerStepsView(entry: entry, circular: family == .accessoryCircular)
    }
}

private struct StepasaurusProgressWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WatchComplicationEntry

    var body: some View {
        WatchCornerProgressView(entry: entry, circular: family == .accessoryCircular)
    }
}

private struct StepasaurusStageWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WatchComplicationEntry

    var body: some View {
        WatchCornerStageView(entry: entry, circular: family == .accessoryCircular)
    }
}

private struct StepasaurusMilestoneWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WatchComplicationEntry

    var body: some View {
        WatchCornerMilestoneView(entry: entry, circular: family == .accessoryCircular)
    }
}

struct StepasaurusCreatureWidget: Widget {
    let kind = "StepasaurusCreature"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchComplicationProvider()) { entry in
            StepasaurusCreatureWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Creature")
        .description("Your egg or dinosaur with a progress ring.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct StepasaurusStepsWidget: Widget {
    let kind = "StepasaurusSteps"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchComplicationProvider()) { entry in
            StepasaurusStepsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Steps")
        .description("Today's synced step count.")
        .supportedFamilies([.accessoryCorner, .accessoryCircular])
    }
}

struct StepasaurusProgressWidget: Widget {
    let kind = "StepasaurusProgress"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchComplicationProvider()) { entry in
            StepasaurusProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Stage %")
        .description("Progress within the current growth stage.")
        .supportedFamilies([.accessoryCorner, .accessoryCircular])
    }
}

struct StepasaurusStageWidget: Widget {
    let kind = "StepasaurusStage"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchComplicationProvider()) { entry in
            StepasaurusStageWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Stage")
        .description("Egg, baby, juvenile, or adult.")
        .supportedFamilies([.accessoryCorner, .accessoryCircular])
    }
}

struct StepasaurusMilestoneWidget: Widget {
    let kind = "StepasaurusMilestone"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchComplicationProvider()) { entry in
            StepasaurusMilestoneWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Next Goal")
        .description("Steps until hatch or next stage.")
        .supportedFamilies([.accessoryCorner, .accessoryCircular])
    }
}

@main
struct StepasaurusWatchWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StepasaurusCreatureWidget()
        StepasaurusStepsWidget()
        StepasaurusProgressWidget()
        StepasaurusStageWidget()
        StepasaurusMilestoneWidget()
    }
}
