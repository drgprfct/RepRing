import SwiftUI

@main
struct RepRingApp: App {
    @StateObject private var store = RepStore()
    @StateObject private var healthKit = HealthKitManager()
    @StateObject private var notifications = NotificationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(healthKit)
                .environmentObject(notifications)
        }
    }
}
