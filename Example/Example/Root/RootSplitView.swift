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
                    // A plain selectable row, not `NavigationLink(value:)`: a sidebar link makes
                    // the split view treat the detail column as its navigation target, and on
                    // macOS that wipes the detail stack's bound path after every push — the
                    // pushed screen stays visible while the navigator reads an empty path, so
                    // pops and further programmatic pushes silently stop working.
                    Label { Text(tab.title) } icon: { tab.icon }
                        .tag(tab)
                        // The duplicate titles this row leaves in the tree are handled where
                        // they matter, in `ExampleUITestCase.screenTitleElement`.
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
