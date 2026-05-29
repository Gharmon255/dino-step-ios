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
                    HStack(spacing: 16) {
                        Text("🦕")
                            .font(.title)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(creature.definition.name)
                                .font(.headline)

                            Text("\(creature.definition.rarity.rawValue) · \(creature.definition.habitat.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(creature.completedAt, style: .date)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
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
