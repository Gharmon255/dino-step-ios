//
//  CollectionView.swift
//  Dino Step
//

import SwiftUI

struct CollectionView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        Group {
            if gameState.completedCreatures.isEmpty {
                ContentUnavailableView(
                    "No Dinosaurs Yet",
                    systemImage: "fossil.shell.fill",
                    description: Text("Hatch and grow a dinosaur, then claim your reward to add it here.")
                )
            } else {
                List(gameState.completedCreatures.reversed()) { creature in
                    HStack(spacing: 14) {
                        Text("🦕")
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(creature.definition.name)
                                .font(.headline)

                            HStack(spacing: 6) {
                                RarityBadge(rarity: creature.definition.rarity)
                                Text(creature.definition.habitat.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text("\(creature.totalStepsCompleted.formatted()) steps")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(creature.completedAt, style: .date)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        RarityColors.color(for: creature.definition.rarity).opacity(0.35),
                                        lineWidth: 1
                                    )
                            )
                            .padding(.vertical, 2)
                    )
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Collection")
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        CollectionView(gameState: GameState())
    }
}
