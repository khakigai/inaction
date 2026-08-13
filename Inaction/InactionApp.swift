import SwiftUI
import SwiftData

@main
struct InactionApp: App {
    @State private var settings = AppSettings()
    @State private var navigation = NavigationState()
    @State private var audioEngine = AudioEngine()
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .environment(navigation)
                .environment(audioEngine)
                .environment(authManager)
                .preferredColorScheme(.light)
                .onAppear { authManager.checkCredentialState() }
        }
        .modelContainer(for: [Session.self, BadgeRecord.self])
    }
}
