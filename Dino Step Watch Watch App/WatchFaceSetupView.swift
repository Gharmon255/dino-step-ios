//
//  WatchFaceSetupView.swift
//  Dino Step Watch Watch App
//

import SwiftUI

struct WatchFaceSetupView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Stepasaurus Watch Face")
                    .font(.headline)

                Text(
                    "Apple does not let apps publish a full custom watch face, but you can build one with Infograph:"
                )
                .font(.caption2)
                .foregroundStyle(.secondary)

                Text("Inner circles accept circular complications. Curved outer corners accept corner complications.")
                .font(.caption2)
                .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    setupRow("1", "Long-press your watch face → Edit")
                    setupRow("2", "Choose Infograph or Infograph Modular")
                    setupRow("3", "Inner circle (12 o'clock): Creature")
                    setupRow("4", "Other inner circles: Steps, Stage %, Stage")
                    setupRow("5", "Outer curved corners: Steps, Stage %, Stage, Next Goal")
                }

                Text("Clock hands draw over the center creature — your dino stays underneath.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(
                    "Watch-face circles use a tinted silhouette of your dino (not the full-color art from the app). Open the Stepasaurus watch app for the detailed sprite."
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
    }

    private func setupRow(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(number)
                .font(.caption2.bold())
                .foregroundStyle(.green)
            Text(text)
                .font(.caption2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    WatchFaceSetupView()
}
