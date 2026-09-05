//
// Copyright © 2026 Alexander Romanov
// NavigationStacks.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

/// Every tab owns its own stack. `scene:` keys the stack for state restoration, and
/// `navigationAutoReceive` lets values sent from anywhere land on the right stack.
struct LayoutsNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTabs.layouts.id) {
            LayoutsCatalogScreen()
                .navigationAutoReceive(LayoutsDestinations.self)
        }
    }
}

struct FlowsNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTabs.flows.id) {
            FlowsCatalogScreen()
                .navigationCheckpoint(KnownCheckpoints.flows)
                .navigationAutoReceive(FlowsDestinations.self)
        }
    }
}

struct PresentationNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTabs.presentation.id) {
            PresentationCatalogScreen()
                .navigationAutoReceive(PresentationDestinations.self)
        }
    }
}

struct SettingsNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTabs.settings.id) {
            SettingsScreen()
                .navigationAutoReceive(SettingsDestinations.self)
        }
    }
}
