//
//  HomeCollectionStrip.swift
//  Dino Step
//

import SwiftUI

struct HomeCollectionStrip: View {
    let entries: [CollectionRosterEntry]
    let dexDiscovered: Int
    let dexTotal: Int

    private var collectedEntries: [CollectionRosterEntry] {
        entries
            .filter(\.isCollected)
            .sorted {
                ($0.collection?.latestCompletedAt ?? .distantPast) >
                    ($1.collection?.latestCompletedAt ?? .distantPast)
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your dinos · \(dexDiscovered)/\(dexTotal)")
                .font(.headline)

            if collectedEntries.isEmpty {
                Text("Gotta grow them to full adult before your first dino joins the collection.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.secondary.opacity(0.12))
                    )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(collectedEntries) { entry in
                            HomeCollectionChip(entry: entry)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct HomeCollectionChip: View {
    let entry: CollectionRosterEntry

    private var rarityColor: Color {
        RarityColors.color(for: entry.definition.rarity)
    }

    var body: some View {
        VStack(spacing: 6) {
            CreatureStageVisualView(
                creature: entry.definition,
                stage: .adult,
                fixedVisualSize: 52
            )
            .frame(width: 64, height: 64)

            Text(entry.collection?.latestDisplayName ?? entry.definition.name)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if let count = entry.collection?.collectedCount, count > 1 {
                Text("×\(count)")
                    .font(.caption2.bold())
                    .foregroundStyle(rarityColor)
            }
        }
        .frame(width: 88)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(rarityColor.opacity(0.45), lineWidth: 1)
        )
    }
}
