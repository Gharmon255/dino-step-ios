//
//  OnboardingView.swift
//  Dino Step
//

import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let body: String
}

struct OnboardingView: View {
    let onFinished: () -> Void

    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "🥚",
            title: "Welcome to Stepasaurus!",
            body: "Walk every day to hatch mystery eggs and grow dinosaurs for your collection."
        ),
        OnboardingPage(
            emoji: "🦕",
            title: "Every dino is different",
            body: "Not all dinosaurs take the same number of steps. Rarer eggs need more walking to hatch and grow."
        ),
        OnboardingPage(
            emoji: "👟",
            title: "Stay active every day",
            body: "Walk at least 5,000 steps in a day. If you log fewer, your dino goes back to an egg with only 500 steps of progress."
        ),
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            let page = pages[pageIndex]
            Text(page.emoji)
                .font(.system(size: 72))
            Text(page.title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            Text(page.body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(pageIndex == pages.count - 1 ? "Let's go!" : "Next") {
                if pageIndex == pages.count - 1 {
                    onFinished()
                } else {
                    pageIndex += 1
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)

            if pageIndex < pages.count - 1 {
                Button("Skip", action: onFinished)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
    }
}
