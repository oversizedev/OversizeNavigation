//
// Copyright © 2026 Alexander Romanov
// NavigationOpenModifier.swift, created on 30.08.2026
//

import NavigatorUI
import OversizeCore
import SwiftUI

private struct NavigationOpenModifier<Destination: NavigationDestination>: ViewModifier {
    @Binding var destination: Destination?
    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: destination) { _, destination in
                if let destination {
                    Log.debug("🧭 [NAVIGATION] Open: \(destination)")
                    navigator.navigate(to: destination)
                    self.destination = nil
                }
            }
    }
}

public extension View {
    /// Navigates to a `NavigationDestination` on the navigator owning this view whenever the
    /// binding becomes non-nil, then resets it. The destination's own `NavigationMethod` decides
    /// whether it is pushed or presented.
    ///
    /// Unlike ``navigationMove(_:)``, which broadcasts the value and lets an `onNavigationReceive`
    /// handler elsewhere in the tree perform the navigation, this modifier keeps the navigation
    /// local and deterministic — required for screens that are themselves pushed destinations.
    func navigationOpen<Destination: NavigationDestination>(_ destination: Binding<Destination?>) -> some View {
        modifier(NavigationOpenModifier(destination: destination))
    }
}
