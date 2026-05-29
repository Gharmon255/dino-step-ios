//
//  CollectionCatalog.swift
//  Dino Step
//

import Foundation

struct CollectedSpeciesSummary {
    let definition: CreatureDefinition
    let collectedCount: Int
    let latestCompletedAt: Date
}

struct CollectionStats {
    let totalCollected: Int
    let uniqueSpeciesCollected: Int
    let totalPossibleSpecies: Int
    let completionPercentage: Double
    let rarityProgress: [Rarity: RarityCollectionProgress]
}

struct RarityCollectionProgress {
    let collectedUnique: Int
    let totalInRoster: Int

    var label: String {
        "\(collectedUnique)/\(totalInRoster)"
    }
}

struct CollectionRosterEntry: Identifiable {
    let definition: CreatureDefinition
    let collection: CollectedSpeciesSummary?

    var id: UUID { definition.id }
    var isCollected: Bool { collection != nil }
}

enum CollectionFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    case collected = "Collected"
    case locked = "Locked"

    var id: String { rawValue }
}

enum CollectionSort: String, CaseIterable, Identifiable {
    case rarity = "Rarity"
    case name = "Name"
    case collectedFirst = "Collected First"
    case stepRequirement = "Step Requirement"

    var id: String { rawValue }
}

enum CollectionCatalog {
    static func groupedSummaries(from completed: [CompletedCreature]) -> [UUID: CollectedSpeciesSummary] {
        Dictionary(grouping: completed, by: \.definition.id).mapValues { entries in
            CollectedSpeciesSummary(
                definition: entries[0].definition,
                collectedCount: entries.count,
                latestCompletedAt: entries.map(\.completedAt).max() ?? entries[0].completedAt
            )
        }
    }

    static func stats(from completed: [CompletedCreature]) -> CollectionStats {
        let grouped = groupedSummaries(from: completed)
        let totalPossible = CreatureCatalog.allCreatures.count
        let uniqueCollected = grouped.count

        var rarityProgress: [Rarity: RarityCollectionProgress] = [:]
        for rarity in Rarity.allCases {
            let roster = CreatureCatalog.creatures(for: rarity)
            let collectedInRarity = roster.filter { grouped[$0.id] != nil }.count
            rarityProgress[rarity] = RarityCollectionProgress(
                collectedUnique: collectedInRarity,
                totalInRoster: roster.count
            )
        }

        let completionPercentage = totalPossible > 0
            ? Double(uniqueCollected) / Double(totalPossible) * 100.0
            : 0

        return CollectionStats(
            totalCollected: completed.count,
            uniqueSpeciesCollected: uniqueCollected,
            totalPossibleSpecies: totalPossible,
            completionPercentage: completionPercentage,
            rarityProgress: rarityProgress
        )
    }

    static func rosterEntries(from completed: [CompletedCreature]) -> [CollectionRosterEntry] {
        let grouped = groupedSummaries(from: completed)
        return CreatureCatalog.allCreatures.map { definition in
            CollectionRosterEntry(
                definition: definition,
                collection: grouped[definition.id]
            )
        }
    }

    static func filter(_ entries: [CollectionRosterEntry], by filter: CollectionFilter) -> [CollectionRosterEntry] {
        switch filter {
        case .all:
            return entries
        case .common:
            return entries.filter { $0.definition.rarity == .common }
        case .uncommon:
            return entries.filter { $0.definition.rarity == .uncommon }
        case .rare:
            return entries.filter { $0.definition.rarity == .rare }
        case .epic:
            return entries.filter { $0.definition.rarity == .epic }
        case .legendary:
            return entries.filter { $0.definition.rarity == .legendary }
        case .collected:
            return entries.filter(\.isCollected)
        case .locked:
            return entries.filter { !$0.isCollected }
        }
    }

    static func sort(_ entries: [CollectionRosterEntry], by sort: CollectionSort) -> [CollectionRosterEntry] {
        switch sort {
        case .rarity:
            return entries.sorted { rarityRank($0.definition.rarity) < rarityRank($1.definition.rarity) }
        case .name:
            return entries.sorted { $0.definition.name.localizedCaseInsensitiveCompare($1.definition.name) == .orderedAscending }
        case .collectedFirst:
            return entries.sorted { lhs, rhs in
                if lhs.isCollected != rhs.isCollected {
                    return lhs.isCollected && !rhs.isCollected
                }
                return lhs.definition.name.localizedCaseInsensitiveCompare(rhs.definition.name) == .orderedAscending
            }
        case .stepRequirement:
            return entries.sorted {
                if $0.definition.totalStepsRequired == $1.definition.totalStepsRequired {
                    return $0.definition.name < $1.definition.name
                }
                return $0.definition.totalStepsRequired < $1.definition.totalStepsRequired
            }
        }
    }

    private static func rarityRank(_ rarity: Rarity) -> Int {
        switch rarity {
        case .common: 0
        case .uncommon: 1
        case .rare: 2
        case .epic: 3
        case .legendary: 4
        }
    }
}
