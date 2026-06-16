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
        guard healthKitStepService.isAvailable else {
            let message = HealthKitStepServiceError.unavailable.userMessage
            snapshot.lastHealthKitSyncMessage = message
            return HealthKitStepSyncResult(appliedDelta: 0, message: message)
        }

        if requestAuthorizationIfNeeded,
           healthKitStepService.authorizationStatus() == .notDetermined {
            do {
                try await healthKitStepService.requestAuthorization()
            } catch let error as HealthKitStepServiceError {
                snapshot.lastHealthKitSyncMessage = error.userMessage
                return HealthKitStepSyncResult(appliedDelta: 0, message: error.userMessage)
            } catch {
                let message = error.localizedDescription
                snapshot.lastHealthKitSyncMessage = "HealthKit query failed: \(message)"
                return HealthKitStepSyncResult(appliedDelta: 0, message: message)
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
                let message = "Synced \(delta.formatted()) new steps"
                snapshot.lastHealthKitSyncMessage = message
#if os(iOS)
                StageMilestoneNotifier.notifyIfNeeded(
                    previous: previousCreature,
                    current: snapshot.activeCreature
                )
#endif
                return HealthKitStepSyncResult(appliedDelta: delta, message: message)
            }

            let message = "No new steps to sync"
            snapshot.lastHealthKitSyncMessage = message
            return HealthKitStepSyncResult(appliedDelta: 0, message: message)
        } catch let error as HealthKitStepServiceError {
            snapshot.lastHealthKitSyncMessage = error.userMessage
            return HealthKitStepSyncResult(appliedDelta: 0, message: error.userMessage)
        } catch {
            let message = error.localizedDescription
            snapshot.lastHealthKitSyncMessage = "HealthKit query failed: \(message)"
            return HealthKitStepSyncResult(appliedDelta: 0, message: message)
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
