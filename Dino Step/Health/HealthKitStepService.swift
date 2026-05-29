//
//  HealthKitStepService.swift
//  Dino Step
//

import Foundation

#if os(iOS)
import HealthKit
#endif

enum HealthKitAuthorizationStatus: String, Equatable {
    case unavailable = "Unavailable"
    case notDetermined = "Not Determined"
    case authorized = "Authorized"
    case denied = "Denied"
}

enum HealthKitStepServiceError: LocalizedError, Equatable {
    case unavailable
    case permissionDenied
    case queryFailed
    case noStepData

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "HealthKit is unavailable on this device."
        case .permissionDenied:
            "HealthKit step access was denied."
        case .queryFailed:
            "Could not read steps from HealthKit."
        case .noStepData:
            "No step data found for today."
        }
    }

    var userMessage: String {
        switch self {
        case .unavailable:
            "HealthKit unavailable"
        case .permissionDenied:
            "HealthKit permission denied"
        case .queryFailed:
            "HealthKit query failed"
        case .noStepData:
            "No step data for today"
        }
    }
}

@MainActor
final class HealthKitStepService {
#if os(iOS)
    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType(.stepCount)
#endif

    var isAvailable: Bool {
#if os(iOS)
        HKHealthStore.isHealthDataAvailable()
#else
        false
#endif
    }

    func authorizationStatus() -> HealthKitAuthorizationStatus {
#if os(iOS)
        guard isAvailable else { return .unavailable }

        switch healthStore.authorizationStatus(for: stepType) {
        case .notDetermined:
            return .notDetermined
        case .sharingDenied:
            return .denied
        case .sharingAuthorized:
            return .authorized
        @unknown default:
            return .denied
        }
#else
        return .unavailable
#endif
    }

    func requestAuthorization() async throws {
#if os(iOS)
        guard isAvailable else { throw HealthKitStepServiceError.unavailable }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HealthKitStepServiceError.permissionDenied)
                }
            }
        }
#else
        throw HealthKitStepServiceError.unavailable
#endif
    }

    func fetchTodayStepCount() async throws -> Int {
#if os(iOS)
        guard isAvailable else { throw HealthKitStepServiceError.unavailable }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let now = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if error != nil {
                    continuation.resume(throwing: HealthKitStepServiceError.queryFailed)
                    return
                }

                guard let sum = statistics?.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }

                continuation.resume(returning: Int(sum.doubleValue(for: .count())))
            }

            healthStore.execute(query)
        }
#else
        throw HealthKitStepServiceError.unavailable
#endif
    }
}
