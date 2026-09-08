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
    DeferredNavigationQueue.enqueue(operation)
}

/// The queue the deferred operations run on.
///
/// Main-actor isolation alone would not keep them in order: two intents stated in the same
/// update each spawn their own unstructured `Task`, and the actor is free to schedule those in
/// either order — a pop followed by a route could run as a route followed by a pop. One task
/// drains a FIFO buffer instead, so an operation enqueued while the buffer is draining still
/// runs after the ones already in it.
@MainActor
private enum DeferredNavigationQueue {
    private static var operations: [@MainActor () -> Void] = []
    private static var isDraining: Bool = false

    static func enqueue(_ operation: @escaping @MainActor () -> Void) {
        operations.append(operation)

        guard isDraining == false else { return }
        isDraining = true

        Task { @MainActor in
            defer { isDraining = false }
            while operations.isEmpty == false {
                operations.removeFirst()()
            }
        }
    }
}
