//
//  Dino_StepApp.swift
//  Dino Step
//
//  Created by Gary  on 5/29/26.
//

import SwiftUI

@main
struct Dino_StepApp: App {
    init() {
#if os(iOS)
        PhoneWatchConnectivityManager.shared.activate()
        HealthKitBackgroundSyncCoordinator.shared.registerBackgroundTasks()
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
