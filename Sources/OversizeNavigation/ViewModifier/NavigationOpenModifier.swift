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
    @Environment(\.presentsModalsLocally) private var presentsModalsLocally
    @State private var localPresentation: LocalPresentation?

    func body(content: Content) -> some View {
        content
            .onChange(of: destination) { _, destination in
                if let destination {
                    Log.debug("🧭 [NAVIGATION] Open: \(destination)")
                    self.destination = nil
                    deferNavigation { [navigator, presentsModalsLocally, localPresentation = $localPresentation] in
                        if let navigationDestination = destination as? any NavigationDestination {
                            if presentsModalsLocally, navigationDestination.method.presentsModally {
                                localPresentation.wrappedValue = LocalPresentation(destination: navigationDestination)
                            } else {
                                open(navigationDestination, on: navigator)
                            }
                        } else {
                            Log.error("navigationOpen received a value that does not conform to NavigationDestination: \(destination)")
                            assertionFailure("navigationOpen received a value that does not conform to NavigationDestination: \(destination)")
                            navigator.push(destination)
                        }
                    }
                }
            }
            #if os(macOS)
                .sheet(item: $localPresentation) { presentation in
                    ManagedPresentationView(name: presentation.destination.presentationName) {
                        if presentation.destination.method.wrapsInNavigationStack {
                            ManagedNavigationStack(name: presentation.destination.presentationName) {
                                navigator.mappedPresentationView(for: presentation.destination)
                            }
                        } else {
                            navigator.mappedPresentationView(for: presentation.destination)
                        }
                    }
                    .environment(\.presentsModalsLocally, false)
                }
            #endif
    }
}

private struct LocalPresentation: Identifiable {
    let destination: any NavigationDestination

    var id: Int {
        destination.id
    }
}

private extension NavigationMethod {
    var presentsModally: Bool {
        [.sheet, .cover, .managedSheet, .managedCover].contains(self)
    }

    var wrapsInNavigationStack: Bool {
        [.managedSheet, .managedCover].contains(self)
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
