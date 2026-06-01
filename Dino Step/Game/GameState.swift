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
        self.activeCreature = Self.makeMysteryEgg(rarity: .common)

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
        activeCreature = Self.makeMysteryEgg(rarity: outcome.rarity)
        persistCurrentState()
    }

    func giveRandomEgg() {
        let outcome = EggRewardLogic.rollEggReward()
        lastRewardedEggRarity = outcome.rarity
        lastRewardRollPercent = outcome.rollPercent
        activeCreature = Self.makeMysteryEgg(rarity: outcome.rarity)
        persistCurrentState()
    }

    func giveEgg(rarity: Rarity) {
        lastRewardedEggRarity = rarity
        lastRewardRollPercent = nil
        activeCreature = Self.makeMysteryEgg(rarity: rarity)
        persistCurrentState()
    }

    func resetGame() {
        completedCreatures = []
        lastRewardedEggRarity = nil
        lastRewardRollPercent = nil
        activeCreature = Self.makeMysteryEgg(rarity: .common)
        persistCurrentState()
    }

    func clearCollection() {
        completedCreatures = []
        persistCurrentState()
    }

    func forceNewEggForTesting() {
        if let forced = Self.devForcedCreatureName(),
           let definition = CreatureCatalog.creature(named: forced) {
            activeCreature = ActiveCreature(
                eggRarity: definition.rarity,
                definition: definition,
                currentSteps: 0,
                startedAt: Date()
            )
            persistCurrentState()
        } else {
            giveRandomEgg()
        }
    }

    static func devForcedCreatureName() -> String? {
        let value = UserDefaults.standard.string(forKey: devNextEggSpeciesOverrideKey)
        guard let value, !value.isEmpty, value != "RANDOM" else { return nil }
        return value
    }

    static func makeMysteryEgg(rarity: Rarity) -> ActiveCreature {
        let definition: CreatureDefinition

        if let forced = devForcedCreatureName(),
           let forcedDefinition = CreatureCatalog.creature(named: forced) {
            definition = forcedDefinition
        } else {
            definition = CreatureCatalog.creatures(for: rarity).randomElement()!
            #if DEBUG
            if let forced = devForcedCreatureName(), CreatureCatalog.creature(named: forced) == nil {
                print("[DevTesting] Forced egg species not found in catalog: \(forced)")
            }
            #endif
        }

        return ActiveCreature(
            eggRarity: rarity,
            definition: definition,
            currentSteps: 0,
            startedAt: Date()
        )
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
