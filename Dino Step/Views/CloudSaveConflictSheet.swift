//
//  CloudSaveConflictSheet.swift
//  Dino Step
//

import SwiftUI

struct CloudSaveConflictSheet: View {
    let onKeepLocal: () -> Void
    let onUseCloud: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a save")
                .font(.title2.bold())

            Text(
                "This device and your cloud backup both have progress. " +
                    "Keeping this device uploads your current game to the cloud. " +
                    "Using cloud save replaces this device with the backup from your account."
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

            Button("Keep this device", action: onKeepLocal)
                .buttonStyle(.borderedProminent)

            Button("Use cloud save", action: onUseCloud)
                .buttonStyle(.bordered)

            Button("Cancel", action: onDismiss)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .presentationDetents([.medium])
    }
}
