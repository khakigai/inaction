import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(NavigationState.self) private var nav
    @Environment(AppSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [Session]
    @Query private var badgeRecords: [BadgeRecord]

    @State private var showResetAlert = false
    @State private var showFileImporter = false

    var body: some View {
        ZStack {
            DT.cream.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Button { nav.currentScreen = .home } label: {
                        Text("← Back")
                            .font(DT.inter(14))
                            .foregroundStyle(DT.textMuted)
                    }
                    .padding(.bottom, 36)

                    // Feedback section
                    sectionLabel("FEEDBACK")
                    VStack(spacing: 0) {
                        settingsRow("Haptic") {
                            miniToggle(isOn: settings.hapticEnabled) {
                                settings.hapticEnabled.toggle()
                            }
                        }
                        Divider().foregroundStyle(Color(hex: "F0ECE4"))
                        settingsRow("Daily reminder") {
                            miniToggle(isOn: settings.reminderEnabled) {
                                toggleReminder()
                            }
                        }
                    }
                    .background(DT.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
                    .padding(.bottom, 28)

                    // Data section
                    sectionLabel("DATA")
                    VStack(spacing: 0) {
                        actionButton("Export") { exportData() }
                        Divider().foregroundStyle(Color(hex: "F0ECE4"))
                        actionButton("Import") { showFileImporter = true }
                        Divider().foregroundStyle(Color(hex: "F0ECE4"))
                        actionButton("Reset all data", isDanger: true) { showResetAlert = true }
                    }
                    .background(DT.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
                }
                .frame(maxWidth: 360)
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
        }
        .alert("Reset all data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { resetData() }
        } message: {
            Text("This cannot be undone.")
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json]) { result in
            if case .success(let url) = result { importData(from: url) }
        }
    }

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(DT.inter(11, weight: .medium))
            .foregroundStyle(DT.textMuted)
            .kerning(1)
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private func settingsRow(_ label: String, @ViewBuilder trailing: () -> some View) -> some View {
        HStack {
            Text(label)
                .font(DT.inter(14))
                .foregroundStyle(DT.textPrimary)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func miniToggle(isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Capsule()
                    .fill(isOn ? DT.toggleOn : DT.toggleOff)
                    .frame(width: 40, height: 22)
                Circle()
                    .fill(.white)
                    .frame(width: 16, height: 16)
                    .offset(x: isOn ? 9 : -9)
                    .animation(.easeInOut(duration: 0.3), value: isOn)
            }
        }
    }

    @ViewBuilder
    private func actionButton(_ label: String, isDanger: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(DT.inter(14))
                .foregroundStyle(isDanger ? DT.dangerRed : DT.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
        }
    }

    private func toggleReminder() {
        if !settings.reminderEnabled {
            Task {
                let granted = await NotificationManager.shared.requestPermission()
                await MainActor.run {
                    if granted {
                        settings.reminderEnabled = true
                        NotificationManager.shared.scheduleDailyReminder()
                    }
                }
            }
        } else {
            settings.reminderEnabled = false
            NotificationManager.shared.cancelReminder()
        }
    }

    private func exportData() {
        guard let data = DataExporter.exportJSON(
            sessions: sessions,
            badges: badgeRecords,
            lastSeenCount: settings.lastSeenBadgeCount
        ) else { return }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("inaction-\(toDateKey(Date())).json")
        try? data.write(to: tempURL)

        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }

    private func importData(from url: URL) {
        guard url.startAccessingSecurityScopedResource(),
              let data = try? Data(contentsOf: url),
              let imported = DataExporter.importJSON(data) else { return }
        url.stopAccessingSecurityScopedResource()

        for (key, dur) in imported.sessions {
            let session = Session(dateKey: key, durationSeconds: dur)
            modelContext.insert(session)
        }
        for (id, date) in imported.badges {
            let record = BadgeRecord(badgeId: id)
            record.unlockedAt = date
            modelContext.insert(record)
        }
        settings.lastSeenBadgeCount = imported.lastSeenCount
        try? modelContext.save()
        nav.currentScreen = .home
    }

    private func resetData() {
        try? modelContext.delete(model: Session.self)
        try? modelContext.delete(model: BadgeRecord.self)
        settings.lastSeenBadgeCount = 0
        nav.currentScreen = .home
    }
}
