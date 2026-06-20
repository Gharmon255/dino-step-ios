//
//  CollectionSpeciesDetailView.swift
//  Dino Step
//

import SwiftUI

struct CollectionSpeciesDetailView: View {
    @ObservedObject var gameState: GameState
    let entry: CollectionRosterEntry

    @State private var editingCreature: CompletedCreature?

    private var creature: CreatureDefinition { entry.definition }
    private var rarityColor: Color { RarityColors.color(for: creature.rarity) }

    private let detailStages: [GrowthStage] = [.egg, .baby, .juvenile, .adult]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                growthJourneySection
                paleontologyFactSection
                collectionMetaSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(creature.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingCreature) { completed in
            NicknameEditSheet(
                title: "Nickname your dino",
                speciesName: creature.name,
                initialNickname: completed.nickname,
                onSave: { nickname in
                    gameState.updateCompletedCreatureNickname(id: completed.id, rawNickname: nickname)
                }
            )
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                RarityBadge(rarity: creature.rarity)
                Text(creature.habitat.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var growthJourneySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Growth journey")
                .font(.headline)

            ForEach(detailStages, id: \.self) { stage in
                CollectionStageDetailRow(creature: creature, stage: stage)
            }
        }
    }

    private var paleontologyFactSection: some View {
        GameCard(accentColor: rarityColor) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Paleontology fact")
                    .font(.subheadline.weight(.semibold))

                Text(CreatureFacts.forSpecies(creature.speciesId))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var collectionMetaSection: some View {
        if entry.isCollected {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your adults")
                    .font(.headline)

                ForEach(gameState.completedCreatures(for: creature.speciesId)) { completed in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completed.displayName)
                                .font(.subheadline.weight(.semibold))

                            if completed.nickname != nil {
                                Text(creature.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text(completed.completedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text("EX \(completed.exLevel) · \(completed.eggRarityAtHatch.rawValue.capitalized) egg")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }

                        Spacer()

                        Button("Nickname") {
                            editingCreature = completed
                        }
                        .font(.caption.weight(.semibold))
                    }
                }

                if let collection = entry.collection {
                    if collection.collectedCount > 1 {
                        let packMultiplier = BattlePowerCalculator.packMultiplier(packCount: collection.collectedCount)
                        Text("Collected ×\(collection.collectedCount) · Pack bonus ×\(String(format: "%.2f", packMultiplier))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(rarityColor)
                    }
                    Text("Latest adult: \(collection.latestCompletedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct CollectionStageDetailRow: View {
    let creature: CreatureDefinition
    let stage: GrowthStage

    private let visualSize: CGFloat = 72
    private let frameSize: CGFloat = 84

    var body: some View {
        GameCard {
            HStack(alignment: .top, spacing: 14) {
                CreatureStageVisualView(
                    creature: creature,
                    stage: stage,
                    eggRarity: creature.rarity,
                    compact: true,
                    currentSteps: stage == .egg ? creature.hatchStep : 0,
                    fixedVisualSize: visualSize
                )
                .frame(width: frameSize, height: frameSize)

                VStack(alignment: .leading, spacing: 6) {
                    Text(stageTitle)
                        .font(.subheadline.weight(.semibold))

                    Text(CreatureFacts.stepMilestoneLabel(creature: creature, stage: stage))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)

                    Text(CreatureFacts.growthStageNote(creature: creature, stage: stage))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var stageTitle: String {
        switch stage {
        case .egg: "Egg"
        case .baby: "Hatchling"
        case .juvenile: "Juvenile"
        case .adult: "Adult"
        }
    }
}

#Preview {
    NavigationStack {
        CollectionSpeciesDetailView(
            gameState: GameState(),
            entry: CollectionRosterEntry(
                definition: CreatureCatalog.allCreatures[0],
                collection: CollectedSpeciesSummary(
                    definition: CreatureCatalog.allCreatures[0],
                    collectedCount: 1,
                    latestCompletedAt: .now,
                    latestDisplayName: CreatureCatalog.allCreatures[0].name
                )
            )
        )
    }
}
