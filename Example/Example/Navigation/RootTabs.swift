//
// Copyright © 2026 Alexander Romanov
// RootTabs.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import SwiftUI

enum RootTabs: Int, Codable, CaseIterable, Sendable {
    case layouts
    case flows
    case presentation
    case settings
}

extension RootTabs: Tabable {
    var id: String {
        "\(self)"
    }

    var title: String {
        switch self {
        case .layouts: "Layouts"
        case .flows: "Flows"
        case .presentation: "Presentation"
        case .settings: "Settings"
        }
    }

    var icon: Image {
        switch self {
        case .layouts: Image(systemName: "rectangle.3.group")
        case .flows: Image(systemName: "arrow.triangle.branch")
        case .presentation: Image(systemName: "bell.badge")
        case .settings: Image(systemName: "gearshape")
        }
    }
}

extension RootTabs {
    /// The destination type this tab installs a receive handler for. `navigator.send()` is a
    /// broadcast that only the first registered handler answers, so the whole tree may declare
    /// a type once — the stacks and the tests both read this single table.
    var receivedDestinationType: any ReceivableDestination.Type {
        switch self {
        case .layouts: LayoutsDestinations.self
        case .flows: FlowsDestinations.self
        case .presentation: PresentationDestinations.self
        case .settings: SettingsDestinations.self
        }
    }
}

extension RootTabs: @MainActor NavigationDestination {
    var body: some View {
        switch self {
        case .layouts:
            LayoutsNavigationStack()
        case .flows:
            FlowsNavigationStack()
        case .presentation:
            PresentationNavigationStack()
        case .settings:
            SettingsNavigationStack()
        }
    }
}
