//
//  AppleHealthPrivacyCard.swift
//  Dino Step
//

import SwiftUI

/// User-facing HealthKit disclosure shown in Release builds (mirrors Android HealthConnectCard).
struct AppleHealthPrivacyCard: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        GameCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Apple Health")
                    .font(.headline)
                    .foregroundStyle(.teal)

                Text(healthStatusLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(
                    "Step data stays on your device. Stepasaurus reads your step count from Apple Health when you open the app and about once per hour in the background. We do not sell or share your steps for ads."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)

                if gameState.healthKitAuthorizationStatus.isAuthorized {
                    statRow(
                        "Last synced total today",
                        gameState.lastSyncedHealthKitStepTotal.formatted()
                    )
                }

                PrivacyPolicyLink()
            }
        }
    }

    private var healthStatusLine: String {
        if !gameState.isHealthKitAvailable {
            return "Apple Health is not available on this device."
        }
        switch gameState.healthKitAuthorizationStatus {
        case .authorized:
            return "Step access is enabled. Steps sync automatically about every hour."
        case .notDetermined:
            return "Allow step access when prompted to start automatic step sync."
        case .denied:
            return "Step access is off. Enable Health permissions for Stepasaurus in Settings → Health."
        case .unknown, .unavailable:
            return "Step access status is unknown. Try syncing from Home."
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

private extension HealthKitAuthorizationStatus {
    var isAuthorized: Bool {
        self == .authorized
    }
}
