//
// Copyright © 2026 Alexander Romanov
// RootView.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import SwiftUI

/// A single root navigator hosts every presentation in the app, so a sheet requested from a
/// pushed screen in one tab is still owned by something that is actually rendered.
struct RootView: View {
    private let navigator: Navigator = .root(restorationKey: ExampleLaunch.isUITesting ? nil : "Example")

    @State private var rootType: RootType = .defaultForPlatform

    var body: some View {
        rootType
            .onNavigationReceive { (_: ToggleRootType) in
                rootType = rootType.toggled
                return .auto
            }
            .onNavigationRoute(ExampleRouter())
            .navigationRoot(navigator)
    }
}
