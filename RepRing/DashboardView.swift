import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: RepStore
    @EnvironmentObject private var healthKit: HealthKitManager
    @EnvironmentObject private var notifications: NotificationManager
    @State private var isShowingHelp = false

    let openDials: () -> Void

    init(openDials: @escaping () -> Void = {}) {
        self.openDials = openDials
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                DashboardHeader(
                    showHelp: {
                        isShowingHelp = true
                    },
                    reset: {
                    let exportedDateKey = store.today.dateKey
                    let hadHealthExport = store.settings.lastHealthExportSignature != nil
                    store.resetToday()
                    if hadHealthExport {
                        healthKit.deleteTodayWorkout(dateKey: exportedDateKey)
                    }
                })

                HeroImageCard()

                DailyGoalCard(progress: store.todayTotalProgress,
                              current: store.today.total,
                              goal: store.dailyTotalGoal,
                              reminderText: notifications.reminderCounterText(configuredCount: store.activeReminderCount))

                Text("Count your Reps. Day after day.")
                    .font(.title2.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)

                HStack(spacing: 12) {
                    ForEach(ExerciseKind.allCases) { kind in
                        CompactExerciseCard(kind: kind)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
        .background(AppBackdrop())
        .onAppear {
            notifications.refreshSettings()
            runAutoExportIfNeeded()
        }
        .onChange(of: store.today.total) { _, _ in
            runAutoExportIfNeeded()
        }
        .onChange(of: store.settings.healthAutoExportEnabled) { _, isEnabled in
            if isEnabled { runAutoExportIfNeeded() }
        }
        .sheet(isPresented: $isShowingHelp) {
            TodayHelpSheet(openDials: {
                isShowingHelp = false
                openDials()
            })
        }
    }

    private func runAutoExportIfNeeded() {
        let log = store.today
        let signature = store.healthExportSignature(for: log)

        healthKit.autoExportIfNeeded(log: log,
                                     signature: signature,
                                     isEnabled: store.settings.healthAutoExportEnabled,
                                     lastSignature: store.settings.lastHealthExportSignature) { savedSignature in
            if let savedSignature {
                store.markHealthExported(signature: savedSignature)
            }
        }
    }
}

private struct DashboardHeader: View {
    let showHelp: () -> Void
    let reset: () -> Void

    var body: some View {
        ZStack {
            Text("RepRing")
                .font(.title2.bold())

            HStack {
                Button(action: showHelp) {
                    Image(systemName: "questionmark.circle")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.orange)
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("RepRing help")

                Spacer()

                Button(role: .destructive, action: reset) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.orange)
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Reset today's reps")
            }
        }
        .padding(.top, 2)
    }
}

private struct TodayHelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    let openDials: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("RepRing tracks crunches and push-ups with simple daily progress rings.")
                        .font(.title3.bold())
                        .fixedSize(horizontal: false, vertical: true)

                    HelpSection(
                        title: "Build consistency",
                        text: "RepRing helps you build consistency, one small set at a time."
                    )

                    HelpSection(
                        title: "Today",
                        text: "Use the Today screen to log crunches and push-ups throughout the day. Each tap adds your standard set size, so you can track quick mini-sessions without fussing with numbers every time."
                    )

                    HelpSection(
                        title: "Dials",
                        text: "Set your training rhythm in Dials. Choose the standard set size for crunches and push-ups, then set a daily goal for each. RepRing uses these dials to calculate your progress and show how close you are to finishing today's orbit."
                    )

                    HelpSection(
                        title: "Reminders",
                        text: "Use reminders to stay on track. You can schedule multiple daily reminders, such as morning, lunch, and evening. Reminders are stored on your device and only fire when enabled."
                    )

                    HelpSection(
                        title: "Apple Health",
                        text: "Connect Apple Health when you want a bigger fitness picture. After granting Health access, RepRing can export your daily progress as a strength-training workout. You can export manually, or turn on Auto-export so RepRing updates Apple Health when your reps change."
                    )

                    HelpSection(
                        title: "History",
                        text: "Check History to see your streak of effort. The History screen shows previous days, total reps, and how your routine is building over time."
                    )

                    HelpSection(
                        title: "Reset",
                        text: "Reset only clears today. The reset button clears today's crunches and push-ups so you can correct a mistake or start the day over. Your settings, reminders, and history stay safe."
                    )

                    HelpSection(
                        title: "Appearance",
                        text: "Light, Dark, or Automatic. Choose the appearance that fits your screen, your room, or your tiny rep-counting spaceship."
                    )
                }
                .padding(20)
            }
            .background(AppBackdrop())
            .navigationTitle("RepRing Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Got it") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Start tracking")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)

                    Button {
                        openDials()
                    } label: {
                        Text("Open Dials")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(16)
                .background(.ultraThinMaterial)
            }
        }
    }
}

private struct HelpSection: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline.bold())
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct HeroImageCard: View {
    var body: some View {
        Image("hero_combo")
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(radius: 16, y: 9)
            .padding(8)
            .glassCard(cornerRadius: 30)
    }
}

private struct DailyGoalCard: View {
    let progress: Double
    let current: Int
    let goal: Int
    let reminderText: String

    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                ProgressRing(progress: progress, lineWidth: 8, tint: .orange)
                    .frame(width: 66, height: 66)

                VStack(spacing: 0) {
                    Text("\(Int(progress * 100))%")
                        .font(.headline.bold())
                        .monospacedDigit()
                    Text("today")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Daily goal")
                    .font(.headline.bold())
                Text("\(current) / \(goal) total reps")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Label(reminderText, systemImage: "bell.badge")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .glassCard(cornerRadius: 24)
    }
}

private struct CompactExerciseCard: View {
    @EnvironmentObject private var store: RepStore
    let kind: ExerciseKind

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Image(kind.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)

                Spacer(minLength: 4)

                ProgressRing(progress: store.progress(for: kind), lineWidth: 7, tint: kind.tint)
                    .frame(width: 42, height: 42)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(kind.title)
                    .font(.headline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("\(store.today.value(for: kind)) / \(store.goal(for: kind)) reps")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            HStack(spacing: 8) {
                Button {
                    store.addStandardSet(for: kind)
                } label: {
                    Label("+\(store.setSize(for: kind))", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(kind.tint)

                Button {
                    store.undoStandardSet(for: kind)
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .frame(width: 28)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityLabel("Undo \(kind.title) set")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassCard()
    }
}

struct AppBackdrop: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(colors: gradientColors,
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }

    private var gradientColors: [Color] {
        if colorScheme == .dark {
            return [Color(.systemBackground), Color.teal.opacity(0.18), Color.orange.opacity(0.10)]
        }
        return [Color(.systemBackground), Color.orange.opacity(0.10), Color.teal.opacity(0.08)]
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 26) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }
    }
}

#Preview {
    DashboardView()
        .environmentObject(RepStore())
        .environmentObject(HealthKitManager())
        .environmentObject(NotificationManager())
}
