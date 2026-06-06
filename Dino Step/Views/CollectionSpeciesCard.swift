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

    private let collectedArtSize: CGFloat = 72
    private let collectedFrameSize: CGFloat = 88

    var body: some View {
        GameCard(accentColor: entry.isCollected ? rarityColor : rarityColor.opacity(0.35)) {
            HStack(alignment: .center, spacing: 16) {
                visual

                VStack(alignment: .leading, spacing: 8) {
                    headerRow

                    HStack(spacing: 6) {
                        RarityBadge(rarity: entry.definition.rarity)
                        if entry.isCollected {
                            Text(entry.definition.habitat.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("???")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }

                    metadataRows
                }
            }
            .padding(.vertical, 2)
        }
        .opacity(entry.isCollected ? 1.0 : 0.76)
    }

    private var headerRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.isCollected ? entry.definition.name : "Undiscovered")
                    .font(entry.isCollected ? .headline.weight(.bold) : .headline)
                    .foregroundStyle(entry.isCollected ? .primary : .secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                collectionStatusBadge
            }

            Spacer(minLength: 8)

            if let count = entry.collection?.collectedCount, count > 1 {
                Text("×\(count)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(rarityColor.opacity(0.22)))
                    .foregroundStyle(rarityColor)
            }
        }
    }

    @ViewBuilder
    private var metadataRows: some View {
        if entry.isCollected {
            Text("Adult form collected")
                .font(.caption2.weight(.medium))
                .foregroundStyle(rarityColor.opacity(0.9))
        }

        Text("\(entry.definition.totalStepsRequired.formatted()) steps to adult")
            .font(.caption)
            .foregroundStyle(.secondary)

        if let collection = entry.collection {
            Text("Last collected \(collection.latestCompletedAt.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        } else {
            Text("Hatch and grow to discover")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private var collectionStatusBadge: some View {
        HStack(spacing: 4) {
            if entry.isCollected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption2)
            }

            Text(entry.isCollected ? "Collected" : "Locked")
                .font(.caption2.weight(.semibold))
        }
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
        if entry.isCollected {
            collectedVisual
        } else {
            lockedVisual
        }
    }

    private var collectedVisual: some View {
        CreatureStageVisualView(
            creature: entry.definition,
            stage: .adult,
            compact: true,
            fixedVisualSize: collectedArtSize
        )
        .frame(width: collectedFrameSize, height: collectedFrameSize)
        .accessibilityLabel("\(entry.definition.name) adult")
    }

    private var lockedVisual: some View {
        VStack(spacing: 2) {
            Image(systemName: "questionmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Image(systemName: "lock.fill")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
        .frame(width: collectedFrameSize, height: collectedFrameSize)
        .accessibilityLabel("Locked species")
    }
}
