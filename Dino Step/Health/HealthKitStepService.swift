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
    case unknown = "Unknown"

    var authorizedDisplay: String {
        switch self {
        case .authorized: "Yes"
        case .denied: "No"
        case .notDetermined, .unknown: "Unknown"
        case .unavailable: "No"
        }
    }
}

enum HealthKitStepServiceError: LocalizedError {
    case unavailable
    case permissionNotGranted
    case noStepData(isSimulator: Bool)
    case queryFailed(message: String)

    var errorDescription: String? {
        userMessage
    }

    var userMessage: String {
        switch self {
        case .unavailable:
            "HealthKit unavailable on this device"
        case .permissionNotGranted:
            "HealthKit permission not granted"
        case .noStepData(let isSimulator):
            if isSimulator {
                "No step data found today. Fake steps still work for testing."
            } else {
                "No step data found today"
            }
        case .queryFailed(let message):
            "HealthKit query failed: \(message)"
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

    var isRunningOnSimulator: Bool {
        Self.runningOnSimulator
    }

    static var runningOnSimulator: Bool {
#if targetEnvironment(simulator)
        true
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
        case .sharingAuthorized:
            return .authorized
        case .sharingDenied:
            // Read-only apps often remain .sharingDenied even after read access is granted.
            return .unknown
        @unknown default:
            return .unknown
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
                    Self.log("Authorization request failed: \(Self.shortErrorMessage(error))")
                    continuation.resume(throwing: Self.mapError(error, context: "authorization"))
                    return
                }

                if success {
                    Self.log("Authorization request completed")
                    continuation.resume()
                } else {
                    Self.log("Authorization request returned success=false")
                    continuation.resume(throwing: HealthKitStepServiceError.permissionNotGranted)
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

        Self.log("Fetching steps from \(startOfDay) to \(now) (simulator=\(Self.runningOnSimulator))")

        return try await withCheckedThrowingContinuation { continuation in
            let isSimulator = Self.runningOnSimulator
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    Self.log("Statistics query error: \(Self.shortErrorMessage(error))")
                    continuation.resume(throwing: Self.mapError(error, context: "statistics query"))
                    return
                }

                guard statistics != nil else {
                    Self.log("Statistics query returned nil statistics")
                    continuation.resume(
                        throwing: HealthKitStepServiceError.noStepData(isSimulator: isSimulator)
                    )
                    return
                }

                guard let sum = statistics?.sumQuantity() else {
                    Self.log("Statistics query returned no step samples for today")
                    continuation.resume(
                        throwing: HealthKitStepServiceError.noStepData(isSimulator: isSimulator)
                    )
                    return
                }

                let steps = Int(sum.doubleValue(for: .count()))
                Self.log("Statistics query returned \(steps) steps")
                continuation.resume(returning: steps)
            }

            healthStore.execute(query)
        }
#else
        throw HealthKitStepServiceError.unavailable
#endif
    }

#if os(iOS)
    nonisolated private static func mapError(_ error: Error, context: String) -> HealthKitStepServiceError {
        if let hkError = error as? HKError {
            switch hkError.code {
            case .errorAuthorizationDenied, .errorAuthorizationNotDetermined:
                log("HealthKit \(context) authorization issue: \(shortErrorMessage(hkError))")
                return .permissionNotGranted
            default:
                log("HealthKit \(context) HKError: \(shortErrorMessage(hkError))")
                return .queryFailed(message: shortErrorMessage(hkError))
            }
        }

        log("HealthKit \(context) error: \(shortErrorMessage(error))")
        return .queryFailed(message: shortErrorMessage(error))
    }

    nonisolated private static func shortErrorMessage(_ error: Error) -> String {
        let description = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        if description.isEmpty {
            return String(describing: error)
        }
        return description
    }

    nonisolated private static func log(_ message: String) {
        print("[HealthKitStepService] \(message)")
    }
#endif
}
