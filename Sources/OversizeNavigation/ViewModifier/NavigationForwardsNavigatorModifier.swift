//
// Copyright © 2026 Alexander Romanov
// NavigationForwardsNavigatorModifier.swift, created on 16.10.2026
//

import NavigatorUI
import SwiftUI

public extension View {
    /// Hands the navigator of the enclosing stack to every screen the stack pushes.
    ///
    /// On macOS a screen pushed onto a `NavigationStack` in a `NavigationSplitView` detail column
    /// does not inherit the stack's environment, so it reads the root navigator instead of its own:
    /// it shows no back control, and `navigationOpen`, `navigationBack` and a pop land on the root.
    /// Apply this to the root content of every stack, inside the `ManagedNavigationStack`, so each
    /// pushed destination is built with the navigator that actually owns it. Elsewhere it is a no-op
    /// that costs one environment write per push, so stacks apply it on every platform.
    ///
    /// It occupies NavigatorUI's `navigationModifier` slot of that stack, which holds one closure:
    /// do not combine it with a `navigationModifier` of your own on the same stack. It does not
    /// pass on to child stacks — a sheet's stack forwards its own navigator, not this one.
    func navigationForwardsNavigator() -> some View {
        modifier(NavigationForwardsNavigatorModifier())
    }
}

private struct NavigationForwardsNavigatorModifier: ViewModifier {
    @Environment(\.navigator) private var navigator

    func body(content: Content) -> some View {
        content.navigationModifier(inherits: false) { [navigator] destination in
            destination.asAnyView()
                .environment(\.navigator, navigator)
        }
    }
}
