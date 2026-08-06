import SwiftUI
import SwiftData

@main
struct InactionApp: App {
    @State private var settings = AppSettings()
    @State private var navigation = NavigationState()
    @State private var audioEngine = AudioEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .environment(navigation)
                .environment(audioEngine)
                .preferredColorScheme(.light)
        }
        .modelContainer(for: [Session.self, BadgeRecord.self])
    }
}
