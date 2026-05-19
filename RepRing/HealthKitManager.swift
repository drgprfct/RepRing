import Foundation
import HealthKit
import Combine

@MainActor
final class HealthKitManager: ObservableObject {
    @Published var statusMessage = "Health access is optional."

    private let healthStore = HKHealthStore()
    private static let repRingSourceKey = "RepRingSource"
    private static let repRingDayKey = "RepRingDayKey"
    private static let legacyRepRingDayKey = "RepRingDateKey"
    private static let repRingExportKindKey = "RepRingExportKind"

    func refreshAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            statusMessage = "HealthKit is not available on this device."
            return
        }

        switch healthStore.authorizationStatus(for: HKObjectType.workoutType()) {
        case .sharingAuthorized:
            statusMessage = "Connected. RepRing can write workouts to Health."
        case .sharingDenied:
            statusMessage = "Health access is off. Enable workout sharing in Health settings."
        case .notDetermined:
            statusMessage = "Connect to write RepRing workouts to Health."
        @unknown default:
            statusMessage = "Health authorization status is unknown."
        }
    }

    func requestAuthorization(completion: (@MainActor (Bool) -> Void)? = nil) {
        guard HKHealthStore.isHealthDataAvailable() else {
            statusMessage = "HealthKit is not available on this device."
            completion?(false)
            return
        }

        let workoutType = HKObjectType.workoutType()
        let healthStore = healthStore
        healthStore.requestAuthorization(toShare: [workoutType], read: [workoutType]) { success, error in
            Task { @MainActor in
                if let error {
                    self.statusMessage = "Health permission error: \(error.localizedDescription)"
                    completion?(false)
                    return
                }

                let authorized = healthStore.authorizationStatus(for: workoutType) == .sharingAuthorized
                if authorized {
                    self.statusMessage = "Connected. RepRing can write workouts to Health."
                } else {
                    self.statusMessage = success ? "Health access was not granted for workout sharing." : "Health access was not granted."
                }
                completion?(authorized)
            }
        }
    }

    func saveTodayAsWorkout(log: DailyLog, completion: (@MainActor (Bool, String?) -> Void)? = nil) {
        let signature = exportSignature(for: log)
        replaceAndSaveWorkout(log: log,
                              exportKind: "manual",
                              statusPrefix: "Saved today as a strength workout in Health.") { success in
            completion?(success, success ? signature : nil)
        }
    }

    func deleteTodayWorkout(dateKey: String, completion: (@MainActor (Bool) -> Void)? = nil) {
        guard HKHealthStore.isHealthDataAvailable() else {
            statusMessage = "HealthKit is not available on this device."
            completion?(false)
            return
        }

        guard healthStore.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized else {
            completion?(false)
            return
        }

        deleteExistingRepRingWorkout(for: dateKey) { success in
            if success {
                self.statusMessage = "Removed today’s RepRing workout from Health."
            }
            completion?(success)
        }
    }

    func autoExportIfNeeded(log: DailyLog,
                            signature: String,
                            isEnabled: Bool,
                            lastSignature: String?,
                            completion: (@MainActor (String?) -> Void)? = nil) {
        guard isEnabled else {
            completion?(nil)
            return
        }

        guard log.total > 0 else {
            completion?(nil)
            return
        }

        guard signature != lastSignature else {
            completion?(nil)
            return
        }

        guard HKHealthStore.isHealthDataAvailable() else {
            statusMessage = "Auto-export is on, but HealthKit is not available on this device."
            completion?(nil)
            return
        }

        guard healthStore.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized else {
            statusMessage = "Auto-export is on. Connect Apple Health to start syncing."
            completion?(nil)
            return
        }

        replaceAndSaveWorkout(log: log,
                              exportKind: "automatic",
                              statusPrefix: "Auto-exported today to Apple Health.") { success in
            completion?(success ? signature : nil)
        }
    }

    private func replaceAndSaveWorkout(log: DailyLog,
                                       exportKind: String,
                                       statusPrefix: String,
                                       completion: @escaping @MainActor (Bool) -> Void) {
        guard log.total > 0 else {
            statusMessage = "Add a set before exporting to Health."
            completion(false)
            return
        }

        guard HKHealthStore.isHealthDataAvailable() else {
            statusMessage = "HealthKit is not available on this device."
            completion(false)
            return
        }

        guard healthStore.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized else {
            statusMessage = "Connect Apple Health before exporting."
            completion(false)
            return
        }

        deleteExistingRepRingWorkout(for: log.dateKey) { deleted in
            guard deleted else {
                self.statusMessage = "Could not replace today’s previous Health export."
                completion(false)
                return
            }

            self.saveWorkout(log: log, exportKind: exportKind, statusPrefix: statusPrefix, completion: completion)
        }
    }

    private func saveWorkout(log: DailyLog,
                             exportKind: String,
                             statusPrefix: String,
                             completion: @escaping @MainActor (Bool) -> Void) {
        let totalReps = log.total
        let minutes = max(5, min(45, totalReps / 12))
        let end = Date()
        let start = Calendar.current.date(byAdding: .minute, value: -minutes, to: end) ?? end.addingTimeInterval(-300)

        let metadata: [String: Any] = [
            Self.repRingSourceKey: "RepRing",
            Self.repRingDayKey: log.dateKey,
            Self.repRingExportKindKey: exportKind,
            "RepRingCrunches": log.crunches,
            "RepRingPushUps": log.pushUps,
            "RepRingTotalReps": totalReps,
            HKMetadataKeySyncIdentifier: "RepRing.Workout.\(log.dateKey)",
            HKMetadataKeySyncVersion: totalReps,
            HKMetadataKeyIndoorWorkout: true
        ]

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor

        let builder = HKWorkoutBuilder(healthStore: healthStore,
                                       configuration: configuration,
                                       device: .local())

        func finishWithError(_ message: String) {
            Task { @MainActor in
                self.statusMessage = message
                completion(false)
            }
        }

        builder.beginCollection(withStart: start) { success, error in
            if let error {
                finishWithError("Could not start Health workout export: \(error.localizedDescription)")
                return
            }

            guard success else {
                finishWithError("Health did not start the workout export.")
                return
            }

            builder.addMetadata(metadata) { success, error in
                if let error {
                    finishWithError("Could not attach RepRing workout metadata: \(error.localizedDescription)")
                    return
                }

                guard success else {
                    finishWithError("Health did not accept the RepRing workout metadata.")
                    return
                }

                builder.endCollection(withEnd: end) { success, error in
                    if let error {
                        finishWithError("Could not finish Health workout export: \(error.localizedDescription)")
                        return
                    }

                    guard success else {
                        finishWithError("Health did not finish the workout export.")
                        return
                    }

                    builder.finishWorkout { _, error in
                        Task { @MainActor in
                            if let error {
                                self.statusMessage = "Could not save workout: \(error.localizedDescription)"
                                completion(false)
                            } else {
                                self.statusMessage = statusPrefix
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }

    private func deleteExistingRepRingWorkout(for dateKey: String,
                                              completion: @escaping @MainActor (Bool) -> Void) {
        guard let (start, end) = dayBounds(for: dateKey) else {
            completion(true)
            return
        }

        let sourceKey = Self.repRingSourceKey
        let dayKey = Self.repRingDayKey
        let legacyDayKey = Self.legacyRepRingDayKey
        let healthStore = healthStore
        let datePredicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [.strictStartDate])
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .traditionalStrengthTraining)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, workoutPredicate])

        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { _, samples, error in
            if let error {
                Task { @MainActor in
                    self.statusMessage = "Could not inspect Health exports: \(error.localizedDescription)"
                    completion(false)
                }
                return
            }

            let repRingWorkouts = (samples as? [HKWorkout] ?? []).filter { workout in
                guard let metadata = workout.metadata else { return false }
                let source = metadata[sourceKey] as? String
                let modernDateKey = metadata[dayKey] as? String
                let legacyDateKey = metadata[legacyDayKey] as? String
                let hasLegacyRepRingCounts = metadata["RepRingCrunches"] != nil || metadata["RepRingPushUps"] != nil
                return source == "RepRing" && (modernDateKey == dateKey || legacyDateKey == dateKey || hasLegacyRepRingCounts)
            }

            guard !repRingWorkouts.isEmpty else {
                Task { @MainActor in
                    completion(true)
                }
                return
            }

            let objectsToDelete = repRingWorkouts.map { $0 as HKObject }
            healthStore.delete(objectsToDelete) { success, error in
                Task { @MainActor in
                    if let error {
                        self.statusMessage = "Could not remove older RepRing export: \(error.localizedDescription)"
                        completion(false)
                    } else {
                        completion(success)
                    }
                }
            }
        }

        healthStore.execute(query)
    }

    private func exportSignature(for log: DailyLog) -> String {
        "\(log.dateKey)|crunches:\(log.crunches)|pushups:\(log.pushUps)"
    }

    private func dayBounds(for dateKey: String) -> (Date, Date)? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let start = formatter.date(from: dateKey),
              let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else {
            return nil
        }
        return (start, end)
    }
}
