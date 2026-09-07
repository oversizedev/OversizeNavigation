//
// Copyright © 2026 Alexander Romanov
// NavigationCheckpointModifier.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeCore
import SwiftUI

private struct NavigationReturnTriggerModifier<Value>: ViewModifier {
    let checkpoint: NavigationCheckpoint<Value>
    @Binding var trigger: Bool
    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, trigger in
                if trigger {
                    Log.debug("🧭 [NAVIGATION] Return to checkpoint: \(checkpoint.name)")
                    self.trigger = false
                    deferNavigation { [checkpoint, navigator] in
                        navigator.returnToCheckpoint(checkpoint)
                    }
                }
            }
    }
}

private struct NavigationReturnValueModifier<Value: Hashable>: ViewModifier {
    let checkpoint: NavigationCheckpoint<Value>
    @Binding var value: Value?
    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _, value in
                if let value {
                    Log.debug("🧭 [NAVIGATION] Return to checkpoint: \(checkpoint.name) with: \(value)")
                    self.value = nil
                    deferNavigation { [checkpoint, navigator] in
                        navigator.returnToCheckpoint(checkpoint, value: value)
                    }
                }
            }
    }
}

public extension View {
    /// Establishes a named place the navigation system can return to, however deep the stack
    /// has grown by then.
    ///
    /// > Important: `@_disfavoredOverload` is what makes the body call the NavigatorUI overload
    /// rather than itself. A rename there turns this into a compile error, not a runtime trap.
    @_disfavoredOverload
    func navigationCheckpoint<Value>(_ checkpoint: NavigationCheckpoint<Value>) -> some View {
        navigationCheckpoint(checkpoint)
    }

    /// Establishes a named checkpoint that also receives the value handed to it on return.
    @_disfavoredOverload
    func navigationCheckpoint<Value: Hashable>(
        _ checkpoint: NavigationCheckpoint<Value>,
        completion: @escaping (Value) -> Void
    ) -> some View {
        navigationCheckpoint(checkpoint, completion: completion)
    }

    /// Returns to a checkpoint whenever the trigger becomes `true`, then resets it.
    func navigationReturn<Value>(to checkpoint: NavigationCheckpoint<Value>, trigger: Binding<Bool>) -> some View {
        modifier(NavigationReturnTriggerModifier(checkpoint: checkpoint, trigger: trigger))
    }

    /// Returns to a checkpoint and hands it a value whenever the binding becomes non-nil,
    /// then resets it. Replaces the chain of bindings a pushed screen would otherwise need
    /// to report a result back to the screen that started the flow.
    func navigationReturn<Value: Hashable>(to checkpoint: NavigationCheckpoint<Value>, value: Binding<Value?>) -> some View {
        modifier(NavigationReturnValueModifier(checkpoint: checkpoint, value: value))
    }
}
