//
//  CloudSaveMapper.swift
//  Dino Step
//

import Foundation

enum CloudSaveMapper {
    static func toCloud(
        snapshot: GameStateSnapshot,
        revision: Int64,
        updatedAt: String
    ) -> CloudGameSave {
        let active = snapshot.activeCreature
        return CloudGameSave(
            schemaVersion: CloudGameSave.schemaVersion,
            revision: revision,
            updatedAt: updatedAt,
            activeCreature: CloudActiveCreature(
                speciesId: active.definition.speciesId,
                eggRarity: active.eggRarity.rawValue,
                steps: active.currentSteps,
                isRevealed: GameLogic.isHatched(active),
                nickname: active.nickname,
                startedAt: ISO8601DateFormatter().string(from: active.startedAt),
                hatchStep: active.progression.hatchStep,
                juvenileStep: active.progression.juvenileStep,
                totalStepsRequired: active.progression.totalStepsRequired,
                economyVersion: active.progression.economyVersion
            ),
            completedCreatures: snapshot.completedCreatures.map { completed in
                CloudCompletedCreature(
                    id: completed.id.uuidString,
                    speciesId: completed.definition.speciesId,
                    stepsCompleted: completed.totalStepsCompleted,
                    completedAt: ISO8601DateFormatter().string(from: completed.completedAt),
                    nickname: completed.nickname,
                    eggRarityAtHatch: completed.eggRarityAtHatch.rawValue,
                    exSteps: completed.exSteps,
                    exLevel: completed.exLevel
                )
            },
            playerStats: CloudPlayerStats(
                eggsHatched: 0,
                creaturesCompleted: snapshot.completedCreatures.count,
                lastSyncedStepTotal: snapshot.lastSyncedHealthKitStepTotal,
                lastSyncDayStartMillis: Int64(
                    (snapshot.lastHealthKitSyncDayStart ?? Date(timeIntervalSince1970: 0)).timeIntervalSince1970 * 1000
                ),
                lifetimeStepsApplied: snapshot.lifetimeStepsApplied
            ),
            lastRewardedEggRarity: snapshot.lastRewardedEggRarity?.rawValue,
            lastRewardRollPercent: snapshot.lastRewardRollPercent
        )
    }

    static func toSnapshot(_ cloud: CloudGameSave) -> GameStateSnapshot? {
        guard let definition = CreatureCatalog.creature(withSpeciesId: cloud.activeCreature.speciesId),
              let eggRarity = Rarity(rawValue: cloud.activeCreature.eggRarity),
              let startedAt = ISO8601DateFormatter().date(from: cloud.activeCreature.startedAt) else {
            return nil
        }

        let progression = ProgressionThresholds(
            hatchStep: cloud.activeCreature.hatchStep,
            juvenileStep: cloud.activeCreature.juvenileStep,
            totalStepsRequired: cloud.activeCreature.totalStepsRequired,
            economyVersion: cloud.activeCreature.economyVersion
        )

        let activeCreature = ActiveCreature(
            eggRarity: eggRarity,
            definition: definition,
            progression: progression,
            currentSteps: cloud.activeCreature.steps,
            startedAt: startedAt,
            nickname: cloud.activeCreature.nickname
        )

        let completedCreatures: [CompletedCreature] = cloud.completedCreatures.compactMap { entry in
            guard let creature = CreatureCatalog.creature(withSpeciesId: entry.speciesId),
                  let completedAt = ISO8601DateFormatter().date(from: entry.completedAt) else {
                return nil
            }
            let id = UUID(uuidString: entry.id) ?? UUID()
            return CompletedCreature(
                id: id,
                definition: creature,
                totalStepsCompleted: entry.stepsCompleted,
                completedAt: completedAt,
                nickname: entry.nickname,
                eggRarityAtHatch: entry.eggRarityAtHatch.flatMap(Rarity.init(rawValue:)) ?? creature.rarity,
                exSteps: entry.exSteps ?? 0,
                exLevel: max(1, entry.exLevel ?? 1)
            )
        }

        return GameStateSnapshot(
            activeCreature: activeCreature,
            completedCreatures: completedCreatures,
            lastRewardedEggRarity: cloud.lastRewardedEggRarity.flatMap(Rarity.init(rawValue:)),
            lastRewardRollPercent: cloud.lastRewardRollPercent,
            lastSyncedHealthKitStepTotal: cloud.playerStats.lastSyncedStepTotal,
            lastHealthKitSyncDayStart: Date(timeIntervalSince1970: TimeInterval(cloud.playerStats.lastSyncDayStartMillis) / 1000),
            lastHealthKitSyncMessage: nil,
            lifetimeStepsApplied: cloud.playerStats.lifetimeStepsApplied
        )
    }

    static func isLocalEmpty(_ snapshot: GameStateSnapshot) -> Bool {
        snapshot.completedCreatures.isEmpty &&
            snapshot.lifetimeStepsApplied == 0 &&
            snapshot.activeCreature.currentSteps == 0 &&
            !GameLogic.isHatched(snapshot.activeCreature)
    }
}
