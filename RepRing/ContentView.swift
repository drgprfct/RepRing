import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: RepStore
    @State private var selectedTab: AppTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView {
                selectedTab = .dials
            }
                .tabItem { Label("Today", systemImage: "figure.strengthtraining.traditional") }
                .tag(AppTab.today)

            SettingsView()
                .tabItem { Label("Dials", systemImage: "dial.medium") }
                .tag(AppTab.dials)

            HistoryView()
                .tabItem { Label("History", systemImage: "chart.bar.xaxis") }
                .tag(AppTab.history)
        }
        .tint(.orange)
        .preferredColorScheme(store.settings.appearanceMode.colorScheme)
    }
}

private enum AppTab {
    case today
    case dials
    case history
}

#Preview {
    ContentView()
        .environmentObject(RepStore())
        .environmentObject(HealthKitManager())
        .environmentObject(NotificationManager())
}
