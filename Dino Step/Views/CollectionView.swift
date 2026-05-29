//
//  CollectionView.swift
//  Dino Step
//

import SwiftUI

struct CollectionView: View {
    @ObservedObject var gameState: GameState

    @State private var selectedFilter: CollectionFilter = .all
    @State private var selectedSort: CollectionSort = .rarity

    private var stats: CollectionStats {
        CollectionCatalog.stats(from: gameState.completedCreatures)
    }

    private var displayedEntries: [CollectionRosterEntry] {
        let entries = CollectionCatalog.rosterEntries(from: gameState.completedCreatures)
        let filtered = CollectionCatalog.filter(entries, by: selectedFilter)
        return CollectionCatalog.sort(filtered, by: selectedSort)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CollectionSummaryView(stats: stats)

                filterSection

                sortSection

                if displayedEntries.isEmpty {
                    emptyFilterState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(displayedEntries) { entry in
                            CollectionSpeciesCard(entry: entry)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Collection")
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CollectionFilter.allCases) { filter in
                        filterChip(filter)
                    }
                }
            }
        }
    }

    private var sortSection: some View {
        HStack {
            Text("Sort")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Picker("Sort", selection: $selectedSort) {
                ForEach(CollectionSort.allCases) { sort in
                    Text(sort.rawValue).tag(sort)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var emptyFilterState: some View {
        GameCard {
            VStack(spacing: 8) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("No dinosaurs match this filter")
                    .font(.subheadline.weight(.semibold))

                Text("Try a different rarity or collection status.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    private func filterChip(_ filter: CollectionFilter) -> some View {
        Button {
            selectedFilter = filter
        } label: {
            Text(filter.rawValue)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selectedFilter == filter ? Color.green.opacity(0.25) : Color(.tertiarySystemFill))
                )
                .foregroundStyle(selectedFilter == filter ? .primary : .secondary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        CollectionView(gameState: GameState())
    }
}
