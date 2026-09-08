//
// Copyright © 2026 Alexander Romanov
// NavigationOpenModifier.swift, created on 30.08.2026
//

import NavigatorUI
import OversizeCore
import SwiftUI

private struct NavigationOpenModifier<Destination: Hashable & Equatable>: ViewModifier {
    @Binding var destination: Destination?
    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: destination) { _, destination in
                if let destination {
                    Log.debug("🧭 [NAVIGATION] Open: \(destination)")
                    self.destination = nil
                    deferNavigation { [navigator] in
                        if let navigationDestination = destination as? any NavigationDestination {
                            open(navigationDestination, on: navigator)
                        } else {
                            Log.error("navigationOpen received a value that does not conform to NavigationDestination: \(destination)")
                            assertionFailure("navigationOpen received a value that does not conform to NavigationDestination: \(destination)")
                            navigator.push(destination)
                        }
                    }
                }
            }
    }
}

@MainActor
private func open(_ destination: some NavigationDestination, on navigator: Navigator) {
    navigator.navigate(to: destination)
}

public extension View {
    /// Navigates to a destination on the navigator owning this view whenever the binding
    /// becomes non-nil, then resets it. When the value conforms to `NavigationDestination`,
    /// its own `NavigationMethod` decides whether it is pushed or presented; otherwise it
    /// is pushed as a plain `Hashable` value.
    ///
    /// Unlike ``navigationMove(_:)``, which broadcasts the value and lets an `onNavigationReceive`
    /// handler elsewhere in the tree perform the navigation, this modifier keeps the navigation
    /// local and deterministic — required for screens that are themselves pushed destinations.
    func navigationOpen<Destination: Hashable & Equatable>(_ destination: Binding<Destination?>) -> some View {
        modifier(NavigationOpenModifier(destination: destination))
    }
}
