//
// Copyright © 2026 Alexander Romanov
// NavigationStacks.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

/// Every tab owns its own stack. `scene:` keys the stack for state restoration, and
/// `navigationAutoReceive` lets values sent from anywhere land on the right stack.
///
/// The received type is read from ``RootTabs/receivedDestinationType`` rather than written out
/// here, so the tree cannot end up with two handlers for one type — the failure that makes a
/// push land in a tab nobody is looking at.
struct LayoutsNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTabs.layouts.id) {
            LayoutsCatalogScreen()
                .navigationAutoReceive(destinationsOf: RootTabs.layouts)
        }
    }
}

struct FlowsNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTabs.flows.id) {
            FlowsCatalogScreen()
                .navigationCheckpoint(KnownCheckpoints.flows)
                .navigationAutoReceive(destinationsOf: RootTabs.flows)
        }
    }
}

struct PresentationNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTabs.presentation.id) {
            PresentationCatalogScreen()
                .navigationAutoReceive(destinationsOf: RootTabs.presentation)
        }
    }
}

struct SettingsNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTabs.settings.id) {
            SettingsScreen()
                .navigationAutoReceive(destinationsOf: RootTabs.settings)
        }
    }
}

private extension View {
    /// Installs the handler for the one destination type the tab owns.
    func navigationAutoReceive(destinationsOf tab: RootTabs) -> AnyView {
        tab.receivedDestinationType.installReceiveHandler(on: self)
    }
}
