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
        #if os(macOS)
            // The sidebar drives the section through plain buttons rather than a `List`
            // selection binding or `NavigationLink(value:)`. Both give the split view's own
            // selection machinery a hand in the detail column, and on macOS that races the
            // detail stack for its bound path — a programmatic push renders the screen while
            // the path is wiped back to empty, so every pop and further push silently dies.
            // The same stack inside a sheet keeps its path, which is what points at the split.
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
