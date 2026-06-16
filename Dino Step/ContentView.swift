//
//  ContentView.swift
//  Dino Step
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var selectedTab = Self.initialTabIndex()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(gameState: gameState)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            NavigationStack {
                CollectionView(gameState: gameState)
            }
            .tabItem {
                Label("Collection", systemImage: "square.grid.2x2.fill")
            }
            .tag(1)

            NavigationStack {
                StatsView(gameState: gameState)
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(2)
        }
        .tint(.green)
        .task {
#if os(iOS)
            gameState.configureAutomaticBackgroundSync()
#endif
            await gameState.syncHealthKitSteps()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            gameState.reloadFromPersistence()
            Task {
                await gameState.syncHealthKitSteps()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .healthKitStepsDidSync)) { _ in
            gameState.reloadFromPersistence()
        }
    }

    private static func initialTabIndex() -> Int {
        guard let argument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-screenshotTab=") }) else {
            return 0
        }

        return Int(argument.replacingOccurrences(of: "-screenshotTab=", with: "")) ?? 0
    }
}

#Preview {
    ContentView()
}
