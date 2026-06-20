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
                BattleView(gameState: gameState)
            }
            .tabItem {
                Label("Battle", systemImage: "bolt.fill")
            }
            .tag(2)

            NavigationStack {
                StatsView(gameState: gameState)
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(3)
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
#if os(iOS)
            gameState.syncToWatch()
#endif
            Task {
                await gameState.syncHealthKitSteps()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .healthKitStepsDidSync)) { _ in
            gameState.reloadFromPersistence()
        }
        .fullScreenCover(isPresented: $gameState.showOnboarding) {
            OnboardingView(onFinished: gameState.completeOnboarding)
        }
        .alert("What's new", isPresented: $gameState.showWhatsNew) {
            Button("Got it", action: gameState.dismissWhatsNew)
        } message: {
            Text(
                "• Daily step goal: walk 5,000+ steps or your dino resets to an egg (500 steps left).\n" +
                    "• Egg cracks, dino facts, and your collection on Home.\n" +
                    "• Steps must flow into Apple Health."
            )
        }
        .alert(
            "Your dino needs more steps",
            isPresented: Binding(
                get: { gameState.inactivityPenaltyAlert != nil },
                set: { isPresented in
                    if !isPresented {
                        gameState.dismissInactivityPenaltyAlert()
                    }
                }
            )
        ) {
            Button("OK", action: gameState.dismissInactivityPenaltyAlert)
        } message: {
            Text(gameState.inactivityPenaltyAlert ?? "")
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
