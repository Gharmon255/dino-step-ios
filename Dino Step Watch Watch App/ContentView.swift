//
//  ContentView.swift
//  Dino Step Watch Watch App
//

import SwiftUI

struct ContentView: View {
    @StateObject private var receiver = WatchConnectivityReceiver.shared

    var body: some View {
        ScrollView {
            if let payload = receiver.payload {
                gameContent(payload: payload, syncStatus: receiver.syncStatus)
            } else {
                waitingContent(syncStatus: receiver.syncStatus)
            }
        }
        .background(Color.black)
        .onAppear {
            receiver.activate()
        }
    }

    @ViewBuilder
    private func gameContent(payload: WatchGameStatePayload, syncStatus: String) -> some View {
        let accentColor = WatchRarityColors.color(forRarityString: payload.rarity)

        VStack(spacing: 6) {
            Text(syncStatus)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(payload.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(payload.stage)
                .font(.caption2.bold())
                .foregroundStyle(accentColor)

            WatchProgressRingView(
                progressPercent: payload.progressPercent,
                accentColor: accentColor,
                placeholderEmoji: payload.placeholderVisual
            )
            .padding(.vertical, 4)

            Text(payload.milestoneText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(payload.updatedAt, style: .time)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func waitingContent(syncStatus: String) -> some View {
        VStack(spacing: 8) {
            Text(syncStatus)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .multilineTextAlignment(.center)

            WatchProgressRingView(
                progressPercent: 0,
                accentColor: .gray,
                placeholderEmoji: "🥚"
            )
            .padding(.vertical, 4)

            Text("Open Dino Step on iPhone")
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
}

#Preview {
    ContentView()
}
