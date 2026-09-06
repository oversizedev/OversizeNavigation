//
// Copyright © 2026 Alexander Romanov
// RootTabView.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

struct RootTabView: View {
    /// Kept in `@State` rather than `@SceneStorage`: a scene-stored binding does not take the
    /// value an `onNavigationReceive` handler assigns to it, which breaks every deep link that
    /// has to switch tab before pushing.
    @State private var selectedTab: RootTabs = .layouts

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(RootTabs.allCases) { tab in
                Tab(value: tab) {
                    tab
                } label: {
                    Label { Text(tab.title) } icon: { tab.icon }
                }
                .accessibilityIdentifier("tab.\(tab.id)")
            }
        }
        // A tab builds its stack the first time it is shown, so the receiver waiting for the
        // destination has to exist before the next value in the queue is delivered.
        .onNavigationReceive(assign: $selectedTab, delay: 0.8)
    }
}

#Preview {
    RootTabView()
}
