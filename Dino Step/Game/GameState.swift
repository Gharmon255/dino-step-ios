//
//  GameState.swift
//  Dino Step
//

import Combine
import Foundation

@MainActor
final class GameState: ObservableObject {
    static let devNextEggSpeciesOverrideKey = "dev.nextEggSpeciesOverride"

    @Published private(set) var activeCreature: ActiveCreature
    @Published private(set) var completedCreatures: [CompletedCreature] = []
    @Published private(set) var lastRewardedEggRarity: Rarity?
    @Published private(set) var lastRewardRollPercent: Double?
    @Published private(set) var persistenceStatus: PersistenceStatus?
    @Published private(set) var lastSyncedHealthKitStepTotal: Int = 0
    @Published private(set) var lastHealthKitSyncDayStart: Date?
    @Published private(set) var lastHealthKitSyncMessage: String?
    @Published private(set) var isHealthKitAvailable = false
    @Published private(set) var healthKitAuthorizationStatus: HealthKitAuthorizationStatus = .unknown
    @Published private(set) var isSyncingHealthKitSteps = false

    private let persistenceStore: GamePersistenceStore
    private let healthKitStepService: HealthKitStepService
#if os(iOS)
    private let watchConnectivityManager: PhoneWatchConnectivityManager
#endif

    init(
        persistenceStore: GamePersistenceStore? = nil,
        healthKitStepService: HealthKitStepService? = nil
    ) {
        let store = persistenceStore ?? GamePersistenceStore()
        let healthKitService = healthKitStepService ?? HealthKitStepService()
        self.persistenceStore = store
        self.healthKitStepService = healthKitService
#if os(iOS)
        self.watchConnectivityManager = PhoneWatchConnectivityManager.shared
#endif
        self.activeCreature = Self.createRandomEggWithRarity(.common)

        switch store.load() {
        case .noSavedState:
            break
        case .success(let savedState):
            if let snapshot = SavedGameStateMapper.restore(from: savedState) {
                apply(snapshot)
                persistenceStatus = .loadedSavedGame
            } else {
                persistenceStatus = .resetAfterInvalidData
                persistCurrentState()
            }
        case .invalidData:
            persistenceStatus = .resetAfterInvalidData
            persistCurrentState()
        }

        refreshHealthKitStatus()
#if os(iOS)
        syncToWatch()
#endif
    }

    var currentEggRarity: Rarity {
        activeCreature.eggRarity
    }

    var currentStage: GrowthStage {
        GameLogic.calculateStage(
            currentSteps: activeCreature.currentSteps,
            creatureDefinition: activeCreature.definition
        )
    }

    var displayName: String {
        GameLogic.displayName(for: activeCreature)
    }

    var progressPercent: Double {
        GameLogic.progressPercent(
            currentSteps: activeCreature.currentSteps,
            creatureDefinition: activeCreature.definition
        )
    }

    var nextMilestone: Int? {
        GameLogic.nextMilestone(
            currentSteps: activeCreature.currentSteps,
            creatureDefinition: activeCreature.definition
        )
    }

    var stepsUntilNextMilestone: Int? {
        GameLogic.stepsUntilNextMilestone(
            currentSteps: activeCreature.currentSteps,
            creatureDefinition: activeCreature.definition
        )
    }

    var revealedCreatureRarity: Rarity? {
        GameLogic.isHatched(activeCreature) ? activeCreature.definition.rarity : nil
    }

    func refreshHealthKitStatus() {
        isHealthKitAvailable = healthKitStepService.isAvailable
        healthKitAuthorizationStatus = healthKitStepService.authorizationStatus()
    }

    func syncHealthKitSteps() async {
        guard !isSyncingHealthKitSteps else { return }

        isSyncingHealthKitSteps = true
        defer {
            isSyncingHealthKitSteps = false
            refreshHealthKitStatus()
        }

        do {
            guard healthKitStepService.isAvailable else {
                throw HealthKitStepServiceError.unavailable
            }

            if healthKitStepService.authorizationStatus() == .notDetermined {
                try await healthKitStepService.requestAuthorization()
                refreshHealthKitStatus()
            }

            resetHealthKitSyncBaselineIfNeeded()

            let currentTotal = try await healthKitStepService.fetchTodayStepCount()
            let delta = currentTotal - lastSyncedHealthKitStepTotal

            if delta > 0 {
                activeCreature.currentSteps += delta
                lastSyncedHealthKitStepTotal = currentTotal
                lastHealthKitSyncMessage = "Synced \(delta.formatted()) new steps"
                persistCurrentState()
            } else {
                lastHealthKitSyncMessage = "No new steps to sync"
                persistCurrentState()
            }
        } catch let error as HealthKitStepServiceError {
            lastHealthKitSyncMessage = error.userMessage
            persistCurrentState()
        } catch {
            let message = error.localizedDescription
            print("[HealthKitStepService] Unexpected sync error: \(message)")
            lastHealthKitSyncMessage = "HealthKit query failed: \(message)"
            persistCurrentState()
        }
    }

    func addSteps(_ amount: Int) {
        guard amount > 0 else { return }
        activeCreature.currentSteps += amount
        persistCurrentState()
    }

    func claimReward() {
        guard currentStage == .adult else { return }

        let completed = CompletedCreature(
            id: UUID(),
            definition: activeCreature.definition,
            totalStepsCompleted: activeCreature.definition.totalStepsRequired,
            completedAt: Date()
        )
        completedCreatures.append(completed)

        let outcome = EggRewardLogic.rollEggReward()
        lastRewardedEggRarity = outcome.rarity
        lastRewardRollPercent = outcome.rollPercent
        activeCreature = Self.createRandomEggWithRarity(outcome.rarity)
        persistCurrentState()
    }

    func giveRandomEgg() {
        createRandomEgg()
    }

    func giveEgg(rarity: Rarity) {
        lastRewardedEggRarity = rarity
        lastRewardRollPercent = nil
        activeCreature = Self.createRandomEggWithRarity(rarity)
        persistCurrentState()
    }

    func resetGame() {
        completedCreatures = []
        lastRewardedEggRarity = nil
        lastRewardRollPercent = nil
        activeCreature = Self.createRandomEggWithRarity(.common)
        persistCurrentState()
    }

    func clearCollection() {
        completedCreatures = []
        persistCurrentState()
    }

    func forceNewEggForTesting() {
        if let speciesId = Self.getCurrentTestSpeciesOverride() {
            createForcedSpeciesEgg(speciesId: speciesId)
        } else {
            createRandomEgg()
        }
    }

    func createRandomEgg() {
        let outcome = EggRewardLogic.rollEggReward()
        lastRewardedEggRarity = outcome.rarity
        lastRewardRollPercent = outcome.rollPercent
        activeCreature = Self.createRandomEggWithRarity(outcome.rarity)
        persistCurrentState()
    }

    func createForcedSpeciesEgg(speciesId: String) {
        guard let definition = CreatureCatalog.creature(withSpeciesId: speciesId) else {
            #if DEBUG
            print("[DevTesting] Unknown test species override: \(speciesId)")
            #endif
            return
        }

        lastRewardedEggRarity = definition.rarity
        lastRewardRollPercent = nil
        activeCreature = ActiveCreature(
            eggRarity: definition.rarity,
            definition: definition,
            currentSteps: 0,
            startedAt: Date()
        )
        persistCurrentState()
    }

    static func getCurrentTestSpeciesOverride() -> String? {
        guard let stored = UserDefaults.standard.string(forKey: devNextEggSpeciesOverrideKey),
              !stored.isEmpty,
              stored != "RANDOM" else {
            return nil
        }
        return resolveTestSpeciesOverride(stored)
    }

    static func getRandomSpeciesForRarity(_ rarity: Rarity) -> CreatureDefinition {
        CreatureCatalog.creatures(for: rarity).randomElement()!
    }

    static func createRandomEggWithRarity(_ rarity: Rarity) -> ActiveCreature {
        ActiveCreature(
            eggRarity: rarity,
            definition: getRandomSpeciesForRarity(rarity),
            currentSteps: 0,
            startedAt: Date()
        )
    }

    private static func resolveTestSpeciesOverride(_ stored: String) -> String? {
        if CreatureCatalog.creature(withSpeciesId: stored) != nil {
            return stored
        }

        if let creature = CreatureCatalog.creature(named: stored) {
            return creature.speciesId
        }

        if let normalized = CreatureAssetVisual.normalizedSpeciesId(from: stored),
           CreatureCatalog.creature(withSpeciesId: normalized) != nil {
            return normalized
        }

        #if DEBUG
        print("[DevTesting] Unrecognized test species override: \(stored)")
        #endif
        return nil
    }

    private func apply(_ snapshot: GameStateSnapshot) {
        activeCreature = snapshot.activeCreature
        completedCreatures = snapshot.completedCreatures
        lastRewardedEggRarity = snapshot.lastRewardedEggRarity
        lastRewardRollPercent = snapshot.lastRewardRollPercent
        lastSyncedHealthKitStepTotal = snapshot.lastSyncedHealthKitStepTotal
        lastHealthKitSyncDayStart = snapshot.lastHealthKitSyncDayStart
        lastHealthKitSyncMessage = snapshot.lastHealthKitSyncMessage
        resetHealthKitSyncBaselineIfNeeded()
    }

    private func resetHealthKitSyncBaselineIfNeeded() {
        let todayStart = Calendar.current.startOfDay(for: Date())

        if lastHealthKitSyncDayStart != todayStart {
            lastSyncedHealthKitStepTotal = 0
            lastHealthKitSyncDayStart = todayStart
        }
    }

    private func persistCurrentState() {
        let snapshot = GameStateSnapshot(
            activeCreature: activeCreature,
            completedCreatures: completedCreatures,
            lastRewardedEggRarity: lastRewardedEggRarity,
            lastRewardRollPercent: lastRewardRollPercent,
            lastSyncedHealthKitStepTotal: lastSyncedHealthKitStepTotal,
            lastHealthKitSyncDayStart: lastHealthKitSyncDayStart,
            lastHealthKitSyncMessage: lastHealthKitSyncMessage
        )
        persistenceStore.save(SavedGameStateMapper.makeSavedState(from: snapshot))
        persistenceStatus = .savedLocally
#if os(iOS)
        syncToWatch()
#endif
    }

#if os(iOS)
    private func syncToWatch() {
        let payload = WatchGameStatePayloadBuilder.build(from: self)
        watchConnectivityManager.send(payload: payload)
    }
#endif
}
