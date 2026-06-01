//
//  CollectionSpeciesCard.swift
//  Dino Step
//

import SwiftUI

struct CollectionSpeciesCard: View {
    let entry: CollectionRosterEntry

    private var rarityColor: Color {
        RarityColors.color(for: entry.definition.rarity)
    }

    var body: some View {
        GameCard(accentColor: rarityColor) {
            HStack(spacing: 14) {
                visual

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.isCollected ? entry.definition.name : "Undiscovered")
                                .font(.headline)
                                .foregroundStyle(entry.isCollected ? .primary : .secondary)

                            collectionStatusBadge
                        }

                        Spacer()

                        if let count = entry.collection?.collectedCount, count > 1 {
                            Text("×\(count)")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(rarityColor.opacity(0.2)))
                                .foregroundStyle(rarityColor)
                        }
                    }

                    HStack(spacing: 6) {
                        RarityBadge(rarity: entry.definition.rarity)
                        Text(entry.isCollected ? entry.definition.habitat.rawValue : "???")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if entry.isCollected {
                        Text("Adult · Discovered")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Text("\(entry.definition.totalStepsRequired.formatted()) steps")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let collection = entry.collection {
                        Text("Last collected \(collection.latestCompletedAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Not yet discovered")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .opacity(entry.isCollected ? 1.0 : 0.88)
    }

    private var collectionStatusBadge: some View {
        Text(entry.isCollected ? "Discovered" : "Locked")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(entry.isCollected ? Color.green.opacity(0.18) : Color(.tertiarySystemFill))
            )
            .foregroundStyle(entry.isCollected ? .green : .secondary)
    }

    @ViewBuilder
    private var visual: some View {
        ZStack {
            if entry.isCollected {
                CreatureStageVisualView(
                    creature: entry.definition,
                    stage: .adult,
                    compact: true
                )
            } else {
                lockedVisual
            }
        }
        .frame(width: 56)
    }

    private var lockedVisual: some View {
        ZStack {
            Circle()
                .fill(Color(.tertiarySystemFill))
                .frame(width: 52, height: 52)

            Circle()
                .strokeBorder(rarityColor.opacity(0.45), lineWidth: 2)
                .frame(width: 52, height: 52)

            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Locked species")
    }
}
