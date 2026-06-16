//
//  WatchComplicationViews.swift
//  Dino Step Watch Widgets
//

import SwiftUI
import WidgetKit

struct WatchCreatureCenterComplicationView: View {
    let entry: WatchComplicationEntry

    private var progress: Double {
        min(max(entry.progressPercent / 100.0, 0), 1)
    }

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Circle()
                .stroke(Color.white.opacity(0.18), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    RarityEggVisual.primaryColor(for: entry.accentColorName),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            WatchComplicationCreatureVisual(
                payload: entry.payload,
                visualSize: 22
            )
        }
    }
}

struct WatchCornerStepsView: View {
    let entry: WatchComplicationEntry
    var circular: Bool = false

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            if circular {
                VStack(spacing: 0) {
                    Text(entry.stepsText)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("steps")
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(entry.stepsText)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        }
    }
}

struct WatchCornerProgressView: View {
    let entry: WatchComplicationEntry
    var circular: Bool = false

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text(entry.progressText)
                .font(.system(size: circular ? 14 : 11, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
    }
}

struct WatchCornerStageView: View {
    let entry: WatchComplicationEntry
    var circular: Bool = false

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text(entry.stageText)
                .font(.system(size: circular ? 10 : 9, weight: .bold))
                .minimumScaleFactor(0.55)
                .lineLimit(circular ? 2 : 1)
                .multilineTextAlignment(.center)
        }
    }
}

struct WatchCornerMilestoneView: View {
    let entry: WatchComplicationEntry
    var circular: Bool = false

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text(entry.milestoneText)
                .font(.system(size: circular ? 8 : 8, weight: .semibold))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(circular ? 3 : 2)
        }
    }
}
