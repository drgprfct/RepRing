import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: RepStore
    @EnvironmentObject private var notifications: NotificationManager
    @EnvironmentObject private var healthKit: HealthKitManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    ForEach(ExerciseKind.allCases) { kind in
                        ExerciseDialCard(kind: kind)
                    }

                    ReminderCard()
                    AppearanceCard()
                    HealthConnectorCard()
                    LegalCard()
                }
                .padding(18)
            }
            .background(AppBackdrop())
            .navigationTitle("Dials")
            .onAppear {
                notifications.refreshSettings()
                healthKit.refreshAuthorizationStatus()
            }
        }
    }
}

private struct ExerciseDialCard: View {
    @EnvironmentObject private var store: RepStore
    let kind: ExerciseKind

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(kind.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)

                VStack(alignment: .leading) {
                    Text(kind.title)
                        .font(.title3.bold())
                    Text("Tune the default set and daily target.")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack(spacing: 18) {
                RepDial(value: setBinding,
                        range: 5...100,
                        step: 5,
                        title: "Set",
                        caption: "reps",
                        tint: kind.tint)
                    .frame(height: 190)

                RepDial(value: goalBinding,
                        range: 10...400,
                        step: 10,
                        title: "Goal",
                        caption: "daily",
                        tint: kind.tint)
                    .frame(height: 190)
            }
        }
        .padding(18)
        .glassCard()
    }

    private var setBinding: Binding<Int> {
        Binding {
            store.setSize(for: kind)
        } set: { newValue in
            store.updateSetSize(newValue, for: kind)
        }
    }

    private var goalBinding: Binding<Int> {
        Binding {
            store.goal(for: kind)
        } set: { newValue in
            store.updateGoal(newValue, for: kind)
        }
    }
}

private struct ReminderCard: View {
    @EnvironmentObject private var store: RepStore
    @EnvironmentObject private var notifications: NotificationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Daily reminders", systemImage: "bell.badge")
                    .font(.title3.bold())
                Spacer()
                Text(notifications.reminderCounterText(configuredCount: store.activeReminderCount))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Text("Set several daily nudges for tiny sessions. Each enabled row becomes its own repeating local notification.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                ForEach($store.settings.reminders) { $reminder in
                    ReminderRow(reminder: $reminder,
                                canDelete: store.settings.reminders.count > 1) {
                        store.removeReminder(id: reminder.id)
                    }
                }
            }

            Button {
                store.addReminder()
                scheduleIfReady()
            } label: {
                Label("Add another reminder", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Text(notifications.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                notifications.requestAuthorizationAndSchedule(reminders: store.settings.reminders,
                                                              crunchGoal: store.settings.crunchGoal,
                                                              pushGoal: store.settings.pushGoal)
            } label: {
                Label("Save reminders", systemImage: "calendar.badge.clock")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(18)
        .glassCard()
        .onAppear {
            notifications.refreshSettings()
        }
        .onChange(of: store.settings.reminders) { _, _ in scheduleIfReady() }
        .onChange(of: store.settings.crunchGoal) { _, _ in scheduleIfReady() }
        .onChange(of: store.settings.pushGoal) { _, _ in scheduleIfReady() }
    }

    private func scheduleIfReady() {
        notifications.scheduleDailyReminders(reminders: store.settings.reminders,
                                             crunchGoal: store.settings.crunchGoal,
                                             pushGoal: store.settings.pushGoal)
    }
}

private struct ReminderRow: View {
    @Binding var reminder: ReminderItem
    let canDelete: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Toggle("Enabled", isOn: $reminder.isEnabled)
                .labelsHidden()

            DatePicker("Reminder time", selection: $reminder.time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
                .frame(maxWidth: .infinity, alignment: .leading)
                .disabled(!reminder.isEnabled)

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.bordered)
            .disabled(!canDelete)
            .accessibilityLabel("Delete reminder")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct AppearanceCard: View {
    @EnvironmentObject private var store: RepStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Appearance", systemImage: store.settings.appearanceMode.iconName)
                .font(.title3.bold())

            Picker("Appearance", selection: $store.settings.appearanceMode) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Text("Choose Automatic to follow iOS, or pin RepRing to light or dark mode.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .glassCard()
    }
}

private struct HealthConnectorCard: View {
    @EnvironmentObject private var store: RepStore
    @EnvironmentObject private var healthKit: HealthKitManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Image("goal_rings")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 66, height: 66)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Apple Health")
                        .font(.title3.bold())
                    Text("Connector lives here in Dials.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            Toggle(isOn: autoExportBinding) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Auto-export to Apple Health")
                        .font(.headline)
                    Text("When you log a set, RepRing updates one Health workout for today instead of stacking duplicates.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .onChange(of: store.settings.healthAutoExportEnabled) { _, isEnabled in
                guard isEnabled else { return }
                healthKit.requestAuthorization { granted in
                    if granted {
                        exportToday()
                    } else {
                        store.setHealthAutoExportEnabled(false)
                    }
                }
            }

            Text(healthKit.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button {
                    healthKit.requestAuthorization()
                } label: {
                    Label("Allow", systemImage: "heart.text.square")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    exportToday()
                } label: {
                    Label("Export Today", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.today.total == 0)
            }
        }
        .padding(18)
        .glassCard()
        .onAppear {
            healthKit.refreshAuthorizationStatus()
        }
    }

    private var autoExportBinding: Binding<Bool> {
        Binding {
            store.settings.healthAutoExportEnabled
        } set: { isEnabled in
            store.setHealthAutoExportEnabled(isEnabled)
        }
    }

    private func exportToday() {
        let log = store.today
        guard log.total > 0 else { return }
        healthKit.saveTodayAsWorkout(log: log) { success, signature in
            if success, let signature {
                store.markHealthExported(signature: signature)
            }
        }
    }
}

private struct LegalCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Release info", systemImage: "checkmark.seal")
                .font(.title3.bold())

            VStack(spacing: 10) {
                Link(destination: ReleaseLinks.privacyPolicy) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Link(destination: ReleaseLinks.support) {
                    Label("Support", systemImage: "questionmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(18)
        .glassCard()
    }
}

private enum ReleaseLinks {
    static let privacyPolicy = URL(string: "https://drgprfct.github.io/RepRing/privacy.html")!
    static let support = URL(string: "https://drgprfct.github.io/RepRing/support.html")!
}

#Preview {
    SettingsView()
        .environmentObject(RepStore())
        .environmentObject(NotificationManager())
        .environmentObject(HealthKitManager())
}
