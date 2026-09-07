//
// Copyright © 2026 Alexander Romanov
// DeferredNavigation.swift, created on 07.09.2026
//

import Foundation

/// Runs a navigation operation after the SwiftUI update that requested it has finished.
///
/// Every binding-driven modifier in this package fires from `onChange`, which runs inside the
/// update transaction that processed the state change. On macOS a `NavigationStack` drops a
/// path mutation made from inside that transaction when the view stating it is itself a pushed
/// destination: the push or pop logs, mutates the path, and nothing on screen moves. The same
/// operation from a toolbar button — which runs outside any transaction — takes effect, which
/// is why the back control works while `.navigationBack(_:)` did not.
///
/// One main-actor hop moves the operation past the in-flight update on every platform. All the
/// modifiers route through this single helper so their operations keep their relative order —
/// deferring some and not others would let two intents stated in one update swap places.
@MainActor
func deferNavigation(_ operation: @escaping @MainActor () -> Void) {
    Task { @MainActor in
        operation()
    }
}
