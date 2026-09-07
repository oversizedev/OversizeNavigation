//
// Copyright © 2026 Alexander Romanov
// RootSplitView.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

struct RootSplitView: View {
    @State private var selectedTab: RootTabs? = .layouts

    var body: some View {
        // macOS gets a plain split pane rather than NavigationSplitView: a detail column there
        // races the stack for its bound path — a programmatic push renders the screen while the
        // path is wiped back to empty, so every pop and further push silently dies. The same
        // stack inside a sheet, or beside an HSplitView sidebar, keeps its path. iPadOS has no
        // such race and keeps the native split behaviour, collapsing included.
        #if os(macOS)
            HSplitView {
                SidebarView(selectedTab: $selectedTab)
                    .frame(minWidth: 200, maxWidth: 280)
                selectedTab
                    .frame(minWidth: 480, maxWidth: .infinity, maxHeight: .infinity)
            }
            .onNavigationReceive(assign: $selectedTab, delay: 0.8)
        #else
            NavigationSplitView {
                SidebarView(selectedTab: $selectedTab)
                    .navigationSplitViewColumnWidth(220)
            } detail: {
                selectedTab
            }
            .onNavigationReceive(assign: $selectedTab, delay: 0.8)
        #endif
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
        // The HSplitView host has no split column dressing the list up, so the sidebar look is
        // stated explicitly; NavigationSplitView applies the same style on its own. The title
        // stays off macOS: outside a split column it would write into the window title, which
        // is where every screen publishes its own name.
        .listStyle(.sidebar)
        #if !os(macOS)
            .navigationTitle("OversizeNavigation")
        #endif
    }
}

#Preview {
    RootSplitView()
}
