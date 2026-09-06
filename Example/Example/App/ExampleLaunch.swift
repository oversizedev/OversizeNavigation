//
// Copyright © 2026 Alexander Romanov
// ExampleLaunch.swift, created on 05.09.2026
//

import Foundation

enum ExampleLaunch {
    /// UI tests need a predictable cold start, so restored navigation state is skipped for them.
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-ExampleUITesting")
    }

    /// Removes every trace of scene state the previous instance left behind.
    ///
    /// macOS remembers how many windows the app had, and an instance killed mid-flight — a
    /// crashed UI test runner is enough — records zero in a way the next launch cannot repair:
    /// restoration reports the window as restored while producing none, and the `WindowGroup`
    /// therefore never opens a fresh one. The app comes up as a menu bar over an empty screen,
    /// which a UI test reads as an accessibility tree with no controls in it.
    ///
    /// The record spans both the saved-state archive and SwiftUI's own bookkeeping in
    /// `UserDefaults`, so `-ApplePersistenceIgnoreState` — which only skips the archive — does
    /// not cure it, and neither does `Scene.restorationBehavior(.disabled)` once the state is
    /// already on disk. Deleting both from `App.init`, before AppKit reads them, does.
    static func resetPersistedState() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }
        for libraryURL in FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask) {
            try? FileManager.default.removeItem(
                at: libraryURL.appendingPathComponent("Saved Application State")
            )
        }
    }
}
