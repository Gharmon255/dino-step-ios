//
//  ContentView.swift
//  Dino Step Watch Watch App
//

import SwiftUI

struct ContentView: View {
    private let data = WatchMockGameData.sample

    private var accentColor: Color {
        WatchRarityColors.color(for: data.rarity)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                Text(data.syncStatus)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text(data.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(data.stage)
                    .font(.caption2.bold())
                    .foregroundStyle(accentColor)

                WatchProgressRingView(
                    progressPercent: data.progressPercent,
                    accentColor: accentColor,
                    placeholderEmoji: "🥚"
                )
                .padding(.vertical, 4)

                Text(data.milestoneText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
