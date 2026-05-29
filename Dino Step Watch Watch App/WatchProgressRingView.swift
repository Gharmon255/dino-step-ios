//
//  WatchProgressRingView.swift
//  Dino Step Watch Watch App
//

import SwiftUI

struct WatchProgressRingView: View {
    let progressPercent: Double
    let accentColor: Color
    let placeholderEmoji: String

    private var progress: Double {
        min(max(progressPercent / 100.0, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 6)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text(placeholderEmoji)
                .font(.system(size: 28))

            Text(String(format: "%.0f%%", progressPercent))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .offset(y: 34)
        }
        .frame(width: 96, height: 96)
    }
}

#Preview {
    WatchProgressRingView(
        progressPercent: 25,
        accentColor: WatchRarityColors.color(for: .common),
        placeholderEmoji: "🥚"
    )
}
