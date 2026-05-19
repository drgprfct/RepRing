import XCTest
@testable import RepRing

@MainActor
final class RepRingTests: XCTestCase {
    func testDailyLogReturnsExerciseValuesAndTotal() {
        let log = DailyLog(dateKey: "2026-05-19", crunches: 40, pushUps: 15)

        XCTAssertEqual(log.total, 55)
        XCTAssertEqual(log.value(for: .crunches), 40)
        XCTAssertEqual(log.value(for: .pushUps), 15)
    }

    func testDefaultSettingsKeepRemindersDisabled() {
        let settings = RepSettings()

        XCTAssertEqual(settings.crunchSet, 20)
        XCTAssertEqual(settings.pushSet, 10)
        XCTAssertEqual(settings.crunchGoal, 100)
        XCTAssertEqual(settings.pushGoal, 50)
        XCTAssertEqual(settings.reminders.count, 3)
        XCTAssertTrue(settings.reminders.allSatisfy { !$0.isEnabled })
    }

    func testStorePersistsLogsAndSettingsInInjectedDefaults() {
        let suiteName = "RepRingTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Could not create isolated test defaults.")
            return
        }
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = RepStore(defaults: defaults)
        store.addStandardSet(for: .crunches)
        store.addStandardSet(for: .pushUps)
        store.updateGoal(120, for: .crunches)

        let reloaded = RepStore(defaults: defaults)

        XCTAssertEqual(reloaded.today.crunches, 20)
        XCTAssertEqual(reloaded.today.pushUps, 10)
        XCTAssertEqual(reloaded.settings.crunchGoal, 120)
    }

    func testResetTodayClearsCountsAndExportSignature() {
        let suiteName = "RepRingTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Could not create isolated test defaults.")
            return
        }
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = RepStore(defaults: defaults)
        store.addStandardSet(for: .crunches)
        store.markHealthExported(signature: "test-signature")

        store.resetToday()

        XCTAssertEqual(store.today.total, 0)
        XCTAssertNil(store.settings.lastHealthExportSignature)
    }
}
