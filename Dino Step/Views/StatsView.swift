//
//  StatsView.swift
//  Dino Step
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GameCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Run")
                            .font(.headline)
                            .foregroundStyle(.blue)

                        statRow("Active Steps", "\(gameState.activeCreature.currentSteps.formatted())")
                        statRow("Current Stage", gameState.currentStage.rawValue)
                        statRow("Progress", String(format: "%.1f%%", gameState.progressPercent))
                    }
                }

                GameCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lifetime")
                            .font(.headline)
                            .foregroundStyle(.purple)

                        statRow(
                            "Completed Dinosaurs",
                            "\(gameState.completedCreatures.count)"
                        )
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Stats")
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

#Preview {
    NavigationStack {
        StatsView(gameState: GameState())
    }
}
