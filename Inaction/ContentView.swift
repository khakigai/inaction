import SwiftUI

enum AppScreen: Hashable {
    case home, setup, session, complete, settings, badges
}

@Observable
final class NavigationState {
    var currentScreen: AppScreen = .home
    var lastCompletedDuration: Int = 0
    var lastNewBadges: [BadgeDefinition] = []
}

struct ContentView: View {
    @Environment(NavigationState.self) private var nav
    @Environment(AuthManager.self) private var auth

    // TODO: Re-enable auth gate after Apple Developer Program enrollment
    var body: some View {
        ZStack {
            switch nav.currentScreen {
            case .home:
                HomeView()
                    .transition(.opacity)
            case .setup:
                SetupView()
                    .transition(.opacity)
            case .session:
                SessionView()
                    .transition(.opacity)
            case .complete:
                CompleteView()
                    .transition(.opacity)
            case .settings:
                SettingsView()
                    .transition(.opacity)
            case .badges:
                BadgesView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: nav.currentScreen)
    }
}
