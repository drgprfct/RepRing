import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: RepStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Image("goal_rings")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 260)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Last 7 days")
                            .font(.title2.bold())

                        ForEach(store.recentLogs()) { log in
                            DayRow(log: log,
                                   crunchGoal: store.settings.crunchGoal,
                                   pushGoal: store.settings.pushGoal)
                        }
                    }
                    .padding(18)
                    .glassCard()
                }
                .padding(18)
            }
            .background(AppBackdrop())
            .navigationTitle("History")
        }
    }
}

private struct DayRow: View {
    let log: DailyLog
    let crunchGoal: Int
    let pushGoal: Int

    private var totalGoal: Int { crunchGoal + pushGoal }
    private var progress: Double {
        guard totalGoal > 0 else { return 0 }
        return min(Double(log.total) / Double(totalGoal), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label(for: log.dateKey))
                    .font(.headline)
                Spacer()
                Text("\(log.total) reps")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.secondary.opacity(0.16))
                    Capsule()
                        .fill(LinearGradient(colors: [.teal, .orange], startPoint: .leading, endPoint: .trailing))
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 10)

            Text("Crunches \(log.crunches) • Push-ups \(log.pushUps)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private func label(for key: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: key) else { return key }

        let output = DateFormatter()
        output.dateStyle = .medium
        output.timeStyle = .none
        return output.string(from: date)
    }
}

#Preview {
    HistoryView()
        .environmentObject(RepStore())
}
