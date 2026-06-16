//
//  HealthKitBackgroundSyncCoordinator.swift
//  Dino Step
//

import Foundation

#if os(iOS)
import BackgroundTasks
import HealthKit

@MainActor
final class HealthKitBackgroundSyncCoordinator {
    static let shared = HealthKitBackgroundSyncCoordinator()
    static let backgroundRefreshTaskIdentifier = "com.gharmon255.Dino-Step.healthkit-step-sync"
    private static let hourlyDelivery: HKUpdateFrequency = .hourly

    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType(.stepCount)
    private var observerQuery: HKObserverQuery?
    private var isObserving = false

    private init() {}

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.backgroundRefreshTaskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            self.handleBackgroundRefresh(refreshTask)
        }
    }

    func scheduleHourlyBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            Self.log("Scheduled hourly background refresh")
        } catch {
            Self.log("Failed to schedule background refresh: \(error.localizedDescription)")
        }
    }

    func startAutomaticSyncIfAuthorized(healthKitStepService: HealthKitStepService) {
        guard healthKitStepService.isAvailable else { return }
        guard healthKitStepService.authorizationStatus() != .notDetermined else { return }
        guard healthKitStepService.authorizationStatus() != .denied else { return }

        startObservingStepChanges()
        scheduleHourlyBackgroundRefresh()
    }

    private func startObservingStepChanges() {
        guard !isObserving else { return }

        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error {
                Self.log("Observer query error: \(error.localizedDescription)")
                completionHandler()
                return
            }

            Task { @MainActor in
                await HealthKitStepSyncEngine.syncPersistedGameState()
                self?.scheduleHourlyBackgroundRefresh()
                completionHandler()
            }
        }

        observerQuery = query
        healthStore.execute(query)
        isObserving = true

        healthStore.enableBackgroundDelivery(for: stepType, frequency: Self.hourlyDelivery) { success, error in
            if let error {
                Self.log("enableBackgroundDelivery failed: \(error.localizedDescription)")
            } else if success {
                Self.log("HealthKit hourly background delivery enabled")
            } else {
                Self.log("enableBackgroundDelivery returned success=false")
            }
        }
    }

    private func handleBackgroundRefresh(_ task: BGAppRefreshTask) {
        scheduleHourlyBackgroundRefresh()

        let syncTask = Task { @MainActor in
            await HealthKitStepSyncEngine.syncPersistedGameState()
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = {
            syncTask.cancel()
        }
    }

    private nonisolated static func log(_ message: String) {
        print("[HealthKitBackgroundSync] \(message)")
    }
}
#endif
