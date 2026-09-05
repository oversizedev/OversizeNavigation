//
// Copyright © 2026 Alexander Romanov
// NavigationDismissModifier.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeCore
import SwiftUI

private struct NavigationDismissModifier: ViewModifier {
    @Binding var trigger: Bool
    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, trigger in
                if trigger {
                    Log.debug("🧭 [NAVIGATION] Dismiss")
                    navigator.dismiss()
                    self.trigger = false
                }
            }
    }
}

private struct NavigationDismissAnyModifier: ViewModifier {
    @Binding var trigger: Bool
    let completion: ((Result<Bool, any Error>) -> Void)?
    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, trigger in
                if trigger {
                    Log.debug("🧭 [NAVIGATION] Dismiss any")
                    do {
                        let isDismissed = try navigator.dismissAny()
                        completion?(.success(isDismissed))
                    } catch {
                        completion?(.failure(error))
                    }
                    self.trigger = false
                }
            }
    }
}

public extension View {
    /// Dismisses the presentation this screen lives in whenever the trigger becomes `true`,
    /// then resets it. Use ``navigationBack(_:)`` when the screen only has to leave, whatever
    /// leaving means for the stack it is on.
    func navigationDismiss(_ trigger: Binding<Bool>) -> some View {
        modifier(NavigationDismissModifier(trigger: trigger))
    }

    /// Dismisses every presentation in the navigation tree whenever the trigger becomes `true`,
    /// then resets it. The completion reports whether anything was dismissed, and fails when a
    /// screen marked with ``navigationLocked()`` is on the stack.
    func navigationDismissAny(
        _ trigger: Binding<Bool>,
        completion: ((Result<Bool, any Error>) -> Void)? = nil
    ) -> some View {
        modifier(NavigationDismissAnyModifier(trigger: trigger, completion: completion))
    }
}
