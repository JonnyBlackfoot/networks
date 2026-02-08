import Foundation
import HealthKit
import CoreLocation

public protocol WorkoutEngineProtocol: AnyObject {
    var metrics: WorkoutMetrics { get }
    func requestAuthorization() async throws
    func startWorkout(activity: HKWorkoutActivityType) async throws
    func pauseWorkout() async
    func resumeWorkout() async
    func endWorkout() async throws
}

public struct WorkoutMetrics: Sendable {
    public var heartRate: Double?
    public var activeCalories: Double?
    public var distance: Double?
    public var elapsedTime: TimeInterval
    public var pace: Double?
    public var cadence: Double?
    public var elevationGain: Double?
    public var splits: [TimeInterval]

    public init(
        heartRate: Double? = nil,
        activeCalories: Double? = nil,
        distance: Double? = nil,
        elapsedTime: TimeInterval = 0,
        pace: Double? = nil,
        cadence: Double? = nil,
        elevationGain: Double? = nil,
        splits: [TimeInterval] = []
    ) {
        self.heartRate = heartRate
        self.activeCalories = activeCalories
        self.distance = distance
        self.elapsedTime = elapsedTime
        self.pace = pace
        self.cadence = cadence
        self.elevationGain = elevationGain
        self.splits = splits
    }
}

public final class WorkoutEngine: NSObject, WorkoutEngineProtocol {
    private let healthStore: HKHealthStore
    private let locationManager: CLLocationManager

    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var routeBuilder: HKWorkoutRouteBuilder?

    public private(set) var metrics: WorkoutMetrics = .init()

    public init(healthStore: HKHealthStore = HKHealthStore(), locationManager: CLLocationManager = CLLocationManager()) {
        self.healthStore = healthStore
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }

    public func requestAuthorization() async throws {
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKObjectType.quantityType(forIdentifier: .runningCadence),
            HKObjectType.quantityType(forIdentifier: .runningSpeed),
            HKObjectType.quantityType(forIdentifier: .distanceCycling),
            HKObjectType.quantityType(forIdentifier: .elevationGain),
            HKSeriesType.workoutRoute()
        ].compactMap { $0 }
        try await healthStore.requestAuthorization(toShare: typesToShare, read: Set(typesToRead))
    }

    public func startWorkout(activity: HKWorkoutActivityType) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activity
        configuration.locationType = .outdoor

        let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        let builder = session.associatedWorkoutBuilder()
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        builder.delegate = self

        session.delegate = self
        session.startActivity(with: Date())
        builder.beginCollection(withStart: Date()) { _, _ in }

        routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: .local())
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        self.session = session
        self.builder = builder
    }

    public func pauseWorkout() async {
        session?.pause()
    }

    public func resumeWorkout() async {
        session?.resume()
    }

    public func endWorkout() async throws {
        locationManager.stopUpdatingLocation()
        session?.end()
        guard let builder else { return }
        try await withCheckedThrowingContinuation { continuation in
            builder.endCollection(withEnd: Date()) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    builder.finishWorkout { _, finishError in
                        if let finishError {
                            continuation.resume(throwing: finishError)
                        } else {
                            continuation.resume()
                        }
                    }
                }
            }
        }
    }
}

extension WorkoutEngine: HKWorkoutSessionDelegate {
    public func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        if toState == .ended {
            session = nil
            builder = nil
            routeBuilder = nil
        }
    }

    public func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // TODO: surface error to UI
    }
}

extension WorkoutEngine: HKLiveWorkoutBuilderDelegate {
    public func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // TODO: update split metrics from workout events
    }

    public func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        let statistics = collectedTypes.compactMap { workoutBuilder.statistics(for: $0) }
        updateMetrics(with: statistics)
    }

    private func updateMetrics(with statistics: [HKStatistics]) {
        var next = metrics

        for stat in statistics {
            switch stat.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                next.heartRate = stat.mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute()))
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                next.activeCalories = stat.sumQuantity()?.doubleValue(for: .kilocalorie())
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
                 HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                next.distance = stat.sumQuantity()?.doubleValue(for: .meter())
            case HKQuantityType.quantityType(forIdentifier: .runningCadence):
                next.cadence = stat.mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute()))
            case HKQuantityType.quantityType(forIdentifier: .runningSpeed):
                next.pace = stat.mostRecentQuantity()?.doubleValue(for: .meter().unitDivided(by: .second()))
            case HKQuantityType.quantityType(forIdentifier: .elevationGain):
                next.elevationGain = stat.sumQuantity()?.doubleValue(for: .meter())
            default:
                continue
            }
        }

        metrics = next
    }
}

extension WorkoutEngine: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let routeBuilder else { return }
        routeBuilder.insertRouteData(locations) { _, _ in }
    }
}
