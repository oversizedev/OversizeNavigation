//
// Copyright © 2026 Alexander Romanov
// NavigationRouteModifier.swift, created on 15.08.2026
//

import NavigatorUI
import OversizeCore
import SwiftUI

private struct NavigationRouteModifier<Route: NavigationRoutes>: ViewModifier {
    @Binding var route: Route?
    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: route) { _, route in
                if let route {
                    Log.debug("🧭 [NAVIGATION] Route to: \(route)")
                    navigator.perform(route: route)
                    self.route = nil
                }
            }
    }
}

public extension View {
    /// Performs a cross-module `NavigationRoutes` value whenever the binding becomes non-nil,
    /// then resets it. The route is resolved by whichever `onNavigationRoute` handler the
    /// application installed above this view.
    func navigationRoute<Route: NavigationRoutes>(_ route: Binding<Route?>) -> some View {
        modifier(NavigationRouteModifier(route: route))
    }
}
