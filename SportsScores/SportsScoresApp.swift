import SwiftUI

@main
struct SportsScoresApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = ScoresViewModel()

    var body: some Scene {
        WindowGroup("Sports Scores") {
            MainWindowView(viewModel: viewModel)
                .frame(minWidth: 800, minHeight: 500)
                .task {
                    viewModel.startAutoRefresh()
                }
        }
        .defaultSize(width: 1000, height: 700)
        .commands {
            CommandGroup(replacing: .newItem) { }

            CommandMenu("View") {
                Button("Refresh") {
                    Task { await viewModel.refresh() }
                }
                .keyboardShortcut("r", modifiers: .command)

                Divider()

                Toggle("Show Live Games Only", isOn: $viewModel.showLiveOnly)
                    .keyboardShortcut("l", modifiers: [.command, .shift])
            }
        }

        MenuBarExtra {
            MenuBarView(viewModel: viewModel)
        } label: {
            Label("Sports Scores", systemImage: menuBarIcon)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(viewModel: viewModel)
        }
    }

    private var menuBarIcon: String {
        if viewModel.liveGames.isEmpty {
            return "sportscourt"
        } else {
            return "sportscourt.fill"
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app activates and shows windows
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel: ScoresViewModel
    @AppStorage("refreshInterval") private var refreshInterval: Double = 30

    var body: some View {
        Form {
            Section("Refresh") {
                Picker("Auto-refresh interval", selection: $refreshInterval) {
                    Text("15 seconds").tag(15.0)
                    Text("30 seconds").tag(30.0)
                    Text("1 minute").tag(60.0)
                    Text("5 minutes").tag(300.0)
                }
            }

            Section("Enabled Sports") {
                ForEach(Sport.allCases) { sport in
                    Toggle(sport.displayName, isOn: Binding(
                        get: { viewModel.selectedSports.contains(sport) },
                        set: { _ in viewModel.toggleSport(sport) }
                    ))
                }
            }

            Section("Enabled Leagues") {
                ForEach(League.allCases) { league in
                    Toggle(league.displayName, isOn: Binding(
                        get: { viewModel.selectedLeagues.contains(league) },
                        set: { _ in viewModel.toggleLeague(league) }
                    ))
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 500)
    }
}
