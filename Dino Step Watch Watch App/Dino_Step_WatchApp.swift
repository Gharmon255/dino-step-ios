//
//  Dino_Step_WatchApp.swift
//  Dino Step Watch Watch App
//
//  Created by Gary  on 5/29/26.
//

import SwiftUI

@main
struct Dino_Step_Watch_Watch_AppApp: App {
    init() {
        WatchConnectivityReceiver.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
