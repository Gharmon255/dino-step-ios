//
//  ContentView.swift
//  Dino Step
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()

    var body: some View {
        TabView {
            HomeView(gameState: gameState)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            NavigationStack {
                CollectionView(gameState: gameState)
            }
            .tabItem {
                Label("Collection", systemImage: "square.grid.2x2.fill")
            }

            NavigationStack {
                StatsView(gameState: gameState)
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
        }
        .tint(.green)
    }
}

#Preview {
    ContentView()
}
