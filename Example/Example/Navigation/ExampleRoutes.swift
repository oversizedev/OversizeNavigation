//
// Copyright © 2026 Alexander Romanov
// ExampleRoutes.swift, created on 05.09.2026
//

import NavigatorUI

/// High-level places in the app. A route may need several navigation steps, so callers
/// only name the destination and let ``ExampleRouter`` decide how to get there.
enum ExampleRoutes: NavigationRoutes, Sendable {
    case about
    case hud
    case deepPage
}

extension ExampleRoutes {
    /// The ordered values the router broadcasts for this route.
    var values: [any Hashable] {
        switch self {
        case .about:
            [RootTabs.settings, SettingsDestinations.about]
        case .hud:
            [RootTabs.presentation, PresentationDestinations.hud]
        case .deepPage:
            [RootTabs.flows, FlowsDestinations.page(2), FlowsDestinations.page(3)]
        }
    }
}

struct ExampleRouter: NavigationRouteHandling {
    func route(to route: ExampleRoutes, with navigator: Navigator) {
        navigator.send(values: route.values)
    }
}
