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
    @Published private(set) var lastHealthKitSyncDate: Date?
    @Published private(set) var lifetimeStepsApplied: Int = 0
    @Published private(set) var pendingDiscovery: DiscoveryCelebration?
    @Published private(set) var isHealthKitAvailable = false
    @Published private(set) var healthKitAuthorizationStatus: HealthKitAuthorizationStatus = .unknown
    @Published private(set) var isSyncingHealthKitSteps = false

    private let persistenceStore: GamePersistenceStore
    private let healthKitStepService: HealthKitStepService
    private var lastAutomaticHealthKitSyncAttempt: Date?
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
        watchConnectivityManager.payloadProvider = { [weak self] in
            guard let self else { return nil }
            return WatchGameStatePayloadBuilder.build(from: self)
        }
        syncToWatch()
#endif
    }

#if os(iOS)
    func syncToWatch() {
        let payload = WatchGameStatePayloadBuilder.build(from: self)
        watchConnectivityManager.send(payload: payload)
    }
#endif

    var currentEggRarity: Rarity {
        activeCreature.eggRarity
    }

    var currentStage: GrowthStage {
        GameLogic.calculateStage(
            currentSteps: activeCreature.currentSteps,
            progression: activeCreature.progression
        )
    }

    var displayName: String {
        GameLogic.displayName(for: activeCreature)
    }

    var progressPercent: Double {
        GameLogic.progressPercent(
            currentSteps: activeCreature.currentSteps,
            progression: activeCreature.progression
        )
    }

    var nextMilestone: Int? {
        GameLogic.nextMilestone(
            currentSteps: activeCreature.currentSteps,
            progression: activeCreature.progression
        )
    }

    var stepsUntilNextMilestone: Int? {
        GameLogic.stepsUntilNextMilestone(
            currentSteps: activeCreature.currentSteps,
            progression: activeCreature.progression
        )
    }

    var revealedCreatureRarity: Rarity? {
        GameLogic.isHatched(activeCreature) ? activeCreature.definition.rarity : nil
    }

    var duplicateTradeOffer: DuplicateTradeOffer? {
        DuplicateTradeLogic.offer(
            activeCreature: activeCreature,
            currentStage: currentStage,
            completedCreatures: completedCreatures
        )
    }

    var collectionStats: CollectionStats {
        CollectionCatalog.stats(from: completedCreatures)
    }

    func refreshHealthKitStatus() {
        isHealthKitAvailable = healthKitStepService.isAvailable
        healthKitAuthorizationStatus = healthKitStepService.authorizationStatus()
    }

    func syncHealthKitSteps(manual: Bool = false) async {
        guard !isSyncingHealthKitSteps else { return }

        if !manual,
           let lastAttempt = lastAutomaticHealthKitSyncAttempt,
           Date().timeIntervalSince(lastAttempt) < 120 {
            return
        }
        if !manual {
            lastAutomaticHealthKitSyncAttempt = Date()
        }

        isSyncingHealthKitSteps = true
        defer {
            isSyncingHealthKitSteps = false
            refreshHealthKitStatus()
        }

        let previousCreature = activeCreature
        var currentSnapshot = snapshot()
        _ = await HealthKitStepSyncEngine.sync(
            snapshot: &currentSnapshot,
            healthKitStepService: healthKitStepService,
            requestAuthorizationIfNeeded: true
        )
        apply(currentSnapshot)
        maybeCelebrateDiscovery(previous: previousCreature, current: activeCreature)
        persistCurrentState()

        if healthKitAuthorizationStatus == .authorized {
            lastHealthKitSyncDate = Date()
#if os(iOS)
            StageMilestoneNotifier.requestAuthorizationIfNeeded()
#endif
        }

#if os(iOS)
        HealthKitBackgroundSyncCoordinator.shared.startAutomaticSyncIfAuthorized(
            healthKitStepService: healthKitStepService
        )
#endif
    }

    func configureAutomaticBackgroundSync() {
#if os(iOS)
        HealthKitBackgroundSyncCoordinator.shared.scheduleHourlyBackgroundRefresh()
        HealthKitBackgroundSyncCoordinator.shared.startAutomaticSyncIfAuthorized(
            healthKitStepService: healthKitStepService
        )
#endif
    }

    func snapshot() -> GameStateSnapshot {
        GameStateSnapshot(
            activeCreature: activeCreature,
            completedCreatures: completedCreatures,
            lastRewardedEggRarity: lastRewardedEggRarity,
            lastRewardRollPercent: lastRewardRollPercent,
            lastSyncedHealthKitStepTotal: lastSyncedHealthKitStepTotal,
            lastHealthKitSyncDayStart: lastHealthKitSyncDayStart,
            lastHealthKitSyncMessage: lastHealthKitSyncMessage,
            lifetimeStepsApplied: lifetimeStepsApplied
        )
    }

    func reloadFromPersistence() {
        switch persistenceStore.load() {
        case .success(let savedState):
            if let restored = SavedGameStateMapper.restore(from: savedState) {
                apply(restored)
            }
        case .noSavedState, .invalidData:
            break
        }
    }

    func addSteps(_ amount: Int) {
        guard amount > 0 else { return }
        let previousCreature = activeCreature
        activeCreature.currentSteps += amount
        lifetimeStepsApplied += amount
        maybeCelebrateDiscovery(previous: previousCreature, current: activeCreature)
        persistCurrentState()
#if os(iOS)
        StageMilestoneNotifier.notifyIfNeeded(previous: previousCreature, current: activeCreature)
#endif
    }

    func clearPendingDiscovery() {
        pendingDiscovery = nil
    }

    private func maybeCelebrateDiscovery(previous: ActiveCreature, current: ActiveCreature) {
        guard !GameLogic.isHatched(previous), GameLogic.isHatched(current) else { return }
        pendingDiscovery = DiscoveryCelebration(
            speciesId: current.definition.speciesId,
            speciesName: current.definition.name,
            funFact: CreatureFacts.forSpecies(current.definition.speciesId)
        )
    }

    func claimReward() {
        claimRandomReward()
    }

    func claimRandomReward() {
        guard currentStage == .adult else { return }

        let completedSpeciesId = activeCreature.definition.speciesId
        let collectedSpeciesIds = Set(completedCreatures.map(\.definition.speciesId))

        let completed = CompletedCreature(
            id: UUID(),
            definition: activeCreature.definition,
            totalStepsCompleted: activeCreature.progression.totalStepsRequired,
            completedAt: Date()
        )
        completedCreatures.append(completed)

        let outcome = EggRewardLogic.rollEggReward()
        lastRewardedEggRarity = outcome.rarity
        lastRewardRollPercent = outcome.rollPercent
        activeCreature = Self.createRandomEggWithRarity(
            outcome.rarity,
            excludeSpeciesIds: [completedSpeciesId],
            collectedSpeciesIds: collectedSpeciesIds
        )
        persistCurrentState()
    }

    func tradeDuplicatesForTierUpEgg() {
        guard let offer = duplicateTradeOffer else { return }

        guard DuplicateTradeLogic.removeOneCompleted(
            speciesId: offer.speciesId,
            from: &completedCreatures
        ) else {
            return
        }

        lastRewardedEggRarity = offer.rewardEggRarity
        lastRewardRollPercent = nil
        activeCreature = Self.createRandomEggWithRarity(
            offer.rewardEggRarity,
            excludeSpeciesIds: [offer.speciesId],
            collectedSpeciesIds: Set(completedCreatures.map(\.definition.speciesId))
        )
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
        activeCreature = ActiveCreature.newEgg(
            definition: definition,
            eggRarity: definition.rarity
        )
        persistCurrentState()
    }

    static func getRandomSpeciesForRarity(
        _ rarity: Rarity,
        excludeSpeciesIds: Set<String> = [],
        collectedSpeciesIds: Set<String> = []
    ) -> CreatureDefinition {
        EggSpeciesRoller.rollSpecies(
            rarity: rarity,
            excludeSpeciesIds: excludeSpeciesIds,
            collectedSpeciesIds: collectedSpeciesIds
        )
    }

    static func createRandomEggWithRarity(
        _ rarity: Rarity,
        excludeSpeciesIds: Set<String> = [],
        collectedSpeciesIds: Set<String> = []
    ) -> ActiveCreature {
        ActiveCreature.newEgg(
            definition: getRandomSpeciesForRarity(
                rarity,
                excludeSpeciesIds: excludeSpeciesIds,
                collectedSpeciesIds: collectedSpeciesIds
            ),
            eggRarity: rarity
        )
    }

    static func getCurrentTestSpeciesOverride() -> String? {
        guard let stored = UserDefaults.standard.string(forKey: devNextEggSpeciesOverrideKey),
              !stored.isEmpty,
              stored != "RANDOM" else {
            return nil
        }
        return resolveTestSpeciesOverride(stored)
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
        lifetimeStepsApplied = snapshot.lifetimeStepsApplied
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
            lastHealthKitSyncMessage: lastHealthKitSyncMessage,
            lifetimeStepsApplied: lifetimeStepsApplied
        )
        persistenceStore.save(SavedGameStateMapper.makeSavedState(from: snapshot))
        persistenceStatus = .savedLocally
#if os(iOS)
        syncToWatch()
#endif
    }
}
