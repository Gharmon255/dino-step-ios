//
//  HealthKitStepSyncEngine.swift
//  Dino Step
//

import Foundation

#if os(iOS)
import HealthKit
#endif

struct HealthKitStepSyncResult: Equatable {
    let appliedDelta: Int
    let message: String
    let inactivityPenaltyApplied: Bool
}

enum HealthKitStepSyncBaseline {
    static func resetIfNeeded(snapshot: inout GameStateSnapshot) {
        let todayStart = Calendar.current.startOfDay(for: Date())

        if snapshot.lastHealthKitSyncDayStart != todayStart {
            snapshot.lastSyncedHealthKitStepTotal = 0
            snapshot.lastHealthKitSyncDayStart = todayStart
        }
    }
}

@MainActor
enum HealthKitStepSyncEngine {
    private static var isRunning = false

    static func sync(
        snapshot: inout GameStateSnapshot,
        healthKitStepService: HealthKitStepService,
        requestAuthorizationIfNeeded: Bool = true
    ) async -> HealthKitStepSyncResult {
        let rollover = await DayRolloverEvaluator.evaluateIfNeeded(
            activeCreature: snapshot.activeCreature,
            lastSyncedHealthKitStepTotal: snapshot.lastSyncedHealthKitStepTotal,
            lastHealthKitSyncDayStart: snapshot.lastHealthKitSyncDayStart,
            fetchYesterdaySteps: {
                let calendar = Calendar.current
                let todayStart = calendar.startOfDay(for: Date())
                let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart) ?? todayStart
                return try await healthKitStepService.fetchStepCount(from: yesterdayStart, to: todayStart)
            }
        )
        snapshot.activeCreature = rollover.activeCreature
        let penaltyApplied = rollover.penalty != nil
        if let penalty = rollover.penalty {
#if os(iOS)
            InactivityPenaltyNotifier.notify(yesterdaySteps: penalty.yesterdaySteps)
#endif
        }

        guard healthKitStepService.isAvailable else {
            let message = HealthKitStepServiceError.unavailable.userMessage
            snapshot.lastHealthKitSyncMessage = message
            return HealthKitStepSyncResult(
                appliedDelta: 0,
                message: message,
                inactivityPenaltyApplied: penaltyApplied
            )
        }

        if requestAuthorizationIfNeeded,
           healthKitStepService.authorizationStatus() == .notDetermined {
            do {
                try await healthKitStepService.requestAuthorization()
            } catch let error as HealthKitStepServiceError {
                snapshot.lastHealthKitSyncMessage = error.userMessage
                return HealthKitStepSyncResult(
                    appliedDelta: 0,
                    message: error.userMessage,
                    inactivityPenaltyApplied: penaltyApplied
                )
            } catch {
                let message = error.localizedDescription
                snapshot.lastHealthKitSyncMessage = "HealthKit query failed: \(message)"
                return HealthKitStepSyncResult(
                    appliedDelta: 0,
                    message: message,
                    inactivityPenaltyApplied: penaltyApplied
                )
            }
        }

        HealthKitStepSyncBaseline.resetIfNeeded(snapshot: &snapshot)

        do {
            let currentTotal = try await healthKitStepService.fetchTodayStepCount()
            let delta = currentTotal - snapshot.lastSyncedHealthKitStepTotal

            if delta > 0 {
                let previousCreature = snapshot.activeCreature
                snapshot.activeCreature.currentSteps += delta
                snapshot.lastSyncedHealthKitStepTotal = currentTotal
                snapshot.lifetimeStepsApplied += delta
                if !snapshot.completedCreatures.isEmpty {
                    snapshot.completedCreatures = ExProgression.applyDrip(
                        to: snapshot.completedCreatures,
                        stepAmount: delta
                    )
                }
                let message = "Synced \(delta.formatted()) new steps"
                snapshot.lastHealthKitSyncMessage = message
#if os(iOS)
                StageMilestoneNotifier.notifyIfNeeded(
                    previous: previousCreature,
                    current: snapshot.activeCreature
                )
#endif
                return HealthKitStepSyncResult(
                    appliedDelta: delta,
                    message: message,
                    inactivityPenaltyApplied: penaltyApplied
                )
            }

            let message = "No new steps to sync"
            snapshot.lastHealthKitSyncMessage = message
            return HealthKitStepSyncResult(
                appliedDelta: 0,
                message: message,
                inactivityPenaltyApplied: penaltyApplied
            )
        } catch let error as HealthKitStepServiceError {
            snapshot.lastHealthKitSyncMessage = error.userMessage
            return HealthKitStepSyncResult(
                appliedDelta: 0,
                message: error.userMessage,
                inactivityPenaltyApplied: penaltyApplied
            )
        } catch {
            let message = error.localizedDescription
            snapshot.lastHealthKitSyncMessage = "HealthKit query failed: \(message)"
            return HealthKitStepSyncResult(
                appliedDelta: 0,
                message: "HealthKit query failed: \(message)",
                inactivityPenaltyApplied: penaltyApplied
            )
        }
    }

    @discardableResult
    static func syncPersistedGameState(
        persistenceStore: GamePersistenceStore? = nil,
        healthKitStepService: HealthKitStepService? = nil,
        requestAuthorizationIfNeeded: Bool = false
    ) async -> HealthKitStepSyncResult? {
        guard !isRunning else { return nil }
        isRunning = true
        defer { isRunning = false }

        let store = persistenceStore ?? GamePersistenceStore()
        let stepService = healthKitStepService ?? HealthKitStepService()

        var snapshot: GameStateSnapshot
        switch store.load() {
        case .noSavedState:
            return nil
        case .invalidData:
            return nil
        case .success(let savedState):
            guard let restored = SavedGameStateMapper.restore(from: savedState) else {
                return nil
            }
            snapshot = restored
        }

        let result = await sync(
            snapshot: &snapshot,
            healthKitStepService: stepService,
            requestAuthorizationIfNeeded: requestAuthorizationIfNeeded
        )

        store.save(SavedGameStateMapper.makeSavedState(from: snapshot))

        if result.appliedDelta > 0 {
#if os(iOS)
            let payload = WatchGameStatePayloadBuilder.build(from: snapshot)
            PhoneWatchConnectivityManager.shared.send(payload: payload)
#endif
        }

        NotificationCenter.default.post(name: .healthKitStepsDidSync, object: nil)
        return result
    }
}

extension Notification.Name {
    static let healthKitStepsDidSync = Notification.Name("healthKitStepsDidSync")
}
