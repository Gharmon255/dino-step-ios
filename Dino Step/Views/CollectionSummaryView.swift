//
//  CollectionSummaryView.swift
//  Dino Step
//

import SwiftUI

struct CollectionSummaryView: View {
    let stats: CollectionStats

    var body: some View {
        GameCard(accentColor: .green) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Dino Dex")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Discovered")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(stats.uniqueSpeciesCollected)")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)

                            Text("/ \(stats.totalPossibleSpecies)")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 8)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.0f%%", stats.completionPercentage))
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.green)

                        Text("complete")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }

                ProgressView(value: stats.completionPercentage, total: 100)
                    .tint(.green)

                if stats.totalCollected > stats.uniqueSpeciesCollected {
                    Text("\(stats.totalCollected) adults claimed (\(stats.uniqueSpeciesCollected) unique species)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("By rarity")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ForEach(Rarity.allCases, id: \.self) { rarity in
                        if let progress = stats.rarityProgress[rarity] {
                            rarityProgressRow(rarity: rarity, progress: progress)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func rarityProgressRow(rarity: Rarity, progress: RarityCollectionProgress) -> some View {
        let color = RarityColors.color(for: rarity)
        let fraction = progress.totalInRoster > 0
            ? Double(progress.collectedUnique) / Double(progress.totalInRoster)
            : 0

        HStack(spacing: 8) {
            RarityBadge(rarity: rarity)
                .frame(width: 88, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.18))
                    Capsule()
                        .fill(color.opacity(0.85))
                        .frame(width: max(4, proxy.size.width * fraction))
                }
            }
            .frame(height: 6)

            Text(progress.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 36, alignment: .trailing)
        }
        .frame(height: 24)
    }
}
