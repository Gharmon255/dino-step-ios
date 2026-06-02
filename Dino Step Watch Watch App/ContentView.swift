//
//  ContentView.swift
//  Dino Step Watch Watch App
//

import SwiftUI

struct ContentView: View {
    @StateObject private var receiver = WatchConnectivityReceiver.shared

    var body: some View {
        GeometryReader { proxy in
            let availableHeight = proxy.size.height
            let ringSize = max(74, min(92, availableHeight * 0.42))

            VStack(spacing: 6) {
                if let payload = receiver.payload {
                    gameContent(payload: payload, syncStatus: receiver.syncStatus, ringSize: ringSize)
                } else {
                    waitingContent(syncStatus: receiver.syncStatus, ringSize: ringSize)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            // Extra bottom padding prevents milestone clipping on smaller watch sizes.
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .background(Color.black)
        .onAppear {
            receiver.activate()
        }
    }

    @ViewBuilder
    private func gameContent(payload: WatchGameStatePayload, syncStatus: String, ringSize: CGFloat) -> some View {
        let accentColor = WatchRarityColors.color(forRarityString: payload.rarity)

        VStack(spacing: 4) {
            // Keep, but deemphasize: low-value and can crowd small screens.
            Text(syncStatus.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(payload.displayName)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(payload.stage)
                .font(.caption2.bold())
                .foregroundStyle(accentColor)
                .lineLimit(1)

            WatchProgressRingView(
                progressPercent: payload.ringProgressPercent,
                accentColor: accentColor,
                placeholderEmoji: payload.placeholderVisual,
                ringSize: ringSize,
                eggRarity: payload.rarity,
                speciesId: payload.speciesId,
                creatureName: payload.creatureName,
                stage: payload.stage,
                isEggStage: payload.stage == "EGG"
            )

            // Percent moved out of the ring for clarity.
            Text(String(format: "%.0f%%", payload.ringProgressPercent))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(compactMilestoneText(payload))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .padding(.top, 2)
        }
    }

    @ViewBuilder
    private func waitingContent(syncStatus: String, ringSize: CGFloat) -> some View {
        VStack(spacing: 6) {
            Text(syncStatus.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            WatchProgressRingView(
                progressPercent: 0,
                accentColor: .gray,
                placeholderEmoji: "🥚",
                ringSize: ringSize
            )

            Text("Open Dino Step on iPhone")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }

    private func compactMilestoneText(_ payload: WatchGameStatePayload) -> String {
        // Prefer “X steps to hatch/juvenile/adult”. If space gets tight, drop “steps”.
        let full = payload.milestoneText
        if full.count <= 22 { return full }
        return full.replacingOccurrences(of: " steps ", with: " ")
    }
}

#Preview {
    ContentView()
}
