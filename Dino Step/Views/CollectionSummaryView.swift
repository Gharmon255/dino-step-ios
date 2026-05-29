//
//  CollectionSummaryView.swift
//  Dino Step
//

import SwiftUI

struct CollectionSummaryView: View {
    let stats: CollectionStats

    var body: some View {
        GameCard(accentColor: .purple) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Collection Progress")
                    .font(.headline)
                    .foregroundStyle(.purple)

                HStack(spacing: 16) {
                    summaryMetric("Total", "\(stats.totalCollected)")
                    summaryMetric("Unique", "\(stats.uniqueSpeciesCollected)/\(stats.totalPossibleSpecies)")
                    summaryMetric("Complete", String(format: "%.0f%%", stats.completionPercentage))
                }

                ProgressView(value: stats.completionPercentage, total: 100)
                    .tint(.purple)

                VStack(alignment: .leading, spacing: 8) {
                    Text("By Rarity")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ForEach(Rarity.allCases, id: \.self) { rarity in
                        if let progress = stats.rarityProgress[rarity] {
                            HStack {
                                RarityBadge(rarity: rarity)
                                Spacer()
                                Text(progress.label)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(RarityColors.color(for: rarity))
                            }
                        }
                    }
                }
            }
        }
    }

    private func summaryMetric(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
