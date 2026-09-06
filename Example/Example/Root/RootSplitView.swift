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
