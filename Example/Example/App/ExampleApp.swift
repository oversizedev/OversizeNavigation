//
// Copyright © 2026 Alexander Romanov
// ExampleApp.swift, created on 05.09.2026
//

import OversizeNavigation
import SwiftUI

@main
struct ExampleApp: App {
    init() {
        if ExampleLaunch.isUITesting {
            ExampleLaunch.resetPersistedState()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .presentationHUDRoot()
                .navigationBarAppearanceConfiguration()
        }
        // macOS restores how many windows the scene had, and a run killed mid-flight — a crashed
        // UI test runner is enough — can record zero. Every launch after that brings the app up
        // with a menu bar and no window at all, which a UI test reads as an empty accessibility
        // tree. A demo app has no session worth restoring, so it opts out and always presents;
        // a record already on disk is beyond these modifiers and is wiped by
        // `ExampleLaunch.resetPersistedState()` instead.
        #if os(macOS)
        .restorationBehavior(.disabled)
        .defaultLaunchBehavior(.presented)
        #endif
    }
}
