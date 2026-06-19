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
    @Published var showOnboarding = false
    @Published var showWhatsNew = false
    @Published var inactivityPenaltyAlert: String?

    private let persistenceStore: GamePersistenceStore
    private let healthKitStepService: HealthKitStepService
    let cloudSyncEngine: CloudSaveSyncEngine
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
        self.cloudSyncEngine = CloudSaveSyncEngine(persistenceStore: store)
#if os(iOS)
        self.watchConnectivityManager = PhoneWatchConnectivityManager.shared
#endif
        self.activeCreature = Self.createRandomEggWithRarity(.common)

        cloudSyncEngine.onApplyCloudSave = { [weak self] snapshot in
            guard let self else { return }
            self.apply(snapshot)
            self.persistenceStatus = .loadedSavedGame
#if os(iOS)
            self.syncToWatch()
#endif
        }

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
        refreshExperiencePresentation()
        cloudSyncEngine.refreshSessionOnLaunch(localSnapshot: snapshot())
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
        let result = await HealthKitStepSyncEngine.sync(
            snapshot: &currentSnapshot,
            healthKitStepService: healthKitStepService,
            requestAuthorizationIfNeeded: true
        )
        apply(currentSnapshot)
        if result.inactivityPenaltyApplied {
            inactivityPenaltyAlert = inactivityPenaltyMessage()
        }
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
            completedAt: Date(),
            nickname: activeCreature.nickname
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

    func setActiveCreatureNickname(_ rawNickname: String?) {
        guard GameLogic.isHatched(activeCreature) else { return }

        let nickname = CreatureNickname.normalize(rawNickname)
        guard nickname != activeCreature.nickname else { return }

        activeCreature.nickname = nickname
        persistCurrentState()
#if os(iOS)
        syncToWatch()
#endif
    }

    func updateCompletedCreatureNickname(id: UUID, rawNickname: String?) {
        let nickname = CreatureNickname.normalize(rawNickname)
        guard let index = completedCreatures.firstIndex(where: { $0.id == id }) else { return }
        guard completedCreatures[index].nickname != nickname else { return }

        completedCreatures[index].nickname = nickname
        persistCurrentState()
    }

    func completedCreatures(for speciesId: String) -> [CompletedCreature] {
        completedCreatures
            .filter { $0.definition.speciesId == speciesId }
            .sorted { $0.completedAt > $1.completedAt }
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
        cloudSyncEngine.schedulePush(localSnapshot: snapshot)
#if os(iOS)
        syncToWatch()
#endif
    }

    func completeOnboarding() {
        AppExperienceStore.setOnboardingCompleted()
        AppExperienceStore.setLastSeenWhatsNewVersion(AppExperienceStore.currentWhatsNewVersion)
        refreshExperiencePresentation()
    }

    func dismissWhatsNew() {
        AppExperienceStore.setLastSeenWhatsNewVersion(AppExperienceStore.currentWhatsNewVersion)
        refreshExperiencePresentation()
    }

    func dismissInactivityPenaltyAlert() {
        inactivityPenaltyAlert = nil
    }

    func exportLocalSaveJson() -> String {
        cloudSyncEngine.exportLocalJson(localSnapshot: snapshot())
    }

    func signOutCloudAccount() {
        cloudSyncEngine.signOut()
    }

    func keepLocalCloudSave() {
        cloudSyncEngine.resolveConflictKeepLocal(localSnapshot: snapshot())
    }

    func useCloudSave() {
        Task {
            _ = await cloudSyncEngine.resolveConflictUseCloud()
        }
    }

    func dismissCloudSaveConflict() {
        cloudSyncEngine.dismissConflict()
    }

    func signInWithApple() {
        cloudSyncEngine.signInWithApple(localSnapshot: snapshot())
    }

    func signInWithGoogle() {
        cloudSyncEngine.signInWithGoogle(localSnapshot: snapshot())
    }

#if DEBUG
    func simulateInactiveDayForTesting(yesterdaySteps: Int = 0) async {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        guard let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart) else {
            return
        }

        AppExperienceStore.setLastActivityEvaluationDayStart(yesterdayStart)
        lastSyncedHealthKitStepTotal = max(0, yesterdaySteps)
        lastHealthKitSyncDayStart = yesterdayStart

        let rollover = await DayRolloverEvaluator.evaluateIfNeeded(
            activeCreature: activeCreature,
            lastSyncedHealthKitStepTotal: lastSyncedHealthKitStepTotal,
            lastHealthKitSyncDayStart: lastHealthKitSyncDayStart,
            fetchYesterdaySteps: { max(0, yesterdaySteps) }
        )
        activeCreature = rollover.activeCreature

        if rollover.penalty != nil {
            inactivityPenaltyAlert = inactivityPenaltyMessage()
            lastHealthKitSyncMessage =
                "DEBUG: Inactivity penalty applied (yesterday=\(yesterdaySteps) steps)."
        } else {
            lastHealthKitSyncMessage =
                "DEBUG: No penalty for yesterday=\(yesterdaySteps) steps."
        }

        persistCurrentState()
    }
#endif

    private func refreshExperiencePresentation() {
        showOnboarding = !AppExperienceStore.hasCompletedOnboarding
        showWhatsNew = !showOnboarding &&
            AppExperienceStore.lastSeenWhatsNewVersion < AppExperienceStore.currentWhatsNewVersion
    }

    private func inactivityPenaltyMessage() -> String {
        "You walked fewer than \(DailyActivityPenalty.minimumDailySteps.formatted()) steps yesterday. " +
            "Your dino is back in an egg with \(DailyActivityPenalty.penaltyRemainingSteps) steps of progress. " +
            "Keep walking every day!"
    }
}
