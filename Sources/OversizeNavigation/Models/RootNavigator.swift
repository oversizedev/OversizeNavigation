//
// Copyright © 2026 Alexander Romanov
// RootNavigator.swift, created on 15.08.2026
//

import NavigatorUI
import OversizeCore

public extension Navigator {
    /// Builds the application's root navigator.
    ///
    /// A root navigator is what gives Navigator a single place to host presentations. Without one
    /// every `ManagedNavigationStack` owns an unrelated navigator, and on a split layout with one
    /// stack per sidebar item their presentation state drifts apart — a sheet requested from a
    /// pushed screen sets `sheet` on a navigator that nothing renders, so it never appears.
    ///
    /// Apply the result with `.navigationRoot(_:)` at the top of the scene.
    ///
    /// - Parameters:
    ///   - restorationKey: Key for state restoration. Only destinations that are `Codable` restore.
    ///   - verbosity: How much Navigator logs. Raised to `.info` in debug builds so that sends,
    ///     receives and presentations are visible without adding temporary probes.
    static func root(
        restorationKey: String? = nil,
        verbosity: NavigationEvent.Verbosity = defaultVerbosity,
    ) -> Navigator {
        Navigator(
            configuration: .init(
                restorationKey: restorationKey,
                // Navigator prints to stdout by default, which is invisible unless the app was
                // launched from a terminal. Route it through Log so events land in the unified log.
                logger: { Log.debug("🧭 [NAVIGATION] \($0)") },
                verbosity: verbosity,
            ),
        )
    }

    static var defaultVerbosity: NavigationEvent.Verbosity {
        #if DEBUG
        .info
        #else
        .warning
        #endif
    }
}
