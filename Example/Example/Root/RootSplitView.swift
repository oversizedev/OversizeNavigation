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
        // path is wiped back to empty, so every pop and further push silently dies, whatever
        // drives the sidebar selection. The same stack inside a sheet keeps its path, which is
        // what points at the split itself. The back control moves into the pane's own header
        // (`NavigationLayoutBackToolbarModifier`), since without a split column the window
        // toolbar cannot place it over the detail. iPadOS has no such race and keeps the native
        // split behaviour, collapsing included.
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
        #if os(macOS)
            // Plain buttons rather than a `List` selection binding: the pane hosts no split
            // column, so nothing needs the selection machinery, and a button publishes its
            // selected state through an explicit trait the UI tests can read directly.
            List {
                Section("Example") {
                    ForEach(RootTabs.allCases) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label { Text(tab.title) } icon: { tab.icon }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(tab == selectedTab ? Color.gray.opacity(0.2) : Color.clear)
                        )
                        // The tests read the current section from this trait, the way a bound
                        // selection would have published it.
                        .accessibilityAddTraits(tab == selectedTab ? [.isSelected] : [])
                        .accessibilityIdentifier("sidebar.\(tab.id)")
                    }
                }
            }
            .listStyle(.sidebar)
        #else
            List(selection: $selectedTab) {
                Section("Example") {
                    ForEach(RootTabs.allCases) { tab in
                        // A plain selectable row, not `NavigationLink(value:)` — a sidebar link
                        // navigates the detail column instead of just selecting.
                        Label { Text(tab.title) } icon: { tab.icon }
                            .tag(tab)
                            // The duplicate titles this row leaves in the tree are handled where
                            // they matter, in `ExampleUITestCase.screenTitleElement`.
                            .accessibilityIdentifier("sidebar.\(tab.id)")
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("OversizeNavigation")
        #endif
    }
}

#Preview {
    RootSplitView()
}
