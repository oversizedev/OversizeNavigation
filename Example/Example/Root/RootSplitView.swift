//
// Copyright © 2026 Alexander Romanov
// RootSplitView.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

struct RootSplitView: View {
    @State private var selectedTab: RootTabs? = .layouts

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
                .navigationSplitViewColumnWidth(220)
        } detail: {
            selectedTab
        }
        .onNavigationReceive(assign: $selectedTab, delay: 0.8)
    }
}

private struct SidebarView: View {
    @Binding var selectedTab: RootTabs?

    var body: some View {
        List(selection: $selectedTab) {
            Section("Example") {
                ForEach(RootTabs.allCases) { tab in
                    NavigationLink(value: tab) {
                        Label { Text(tab.title) } icon: { tab.icon }
                    }
                    // Deliberately left as a container rather than collapsed with
                    // `accessibilityElement(children: .ignore)`: collapsing it stops the row from
                    // being published as a button, and `app.buttons["sidebar.flows"]` — which is
                    // how every test reaches a section — silently finds nothing. The duplicate
                    // titles this leaves in the tree are handled where they matter, in
                    // `ExampleUITestCase.screenTitleElement`.
                    .accessibilityIdentifier("sidebar.\(tab.id)")
                }
            }
        }
        .navigationTitle("OversizeNavigation")
    }
}

#Preview {
    RootSplitView()
}
