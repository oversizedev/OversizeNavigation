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
    var id: String { "\(self)" }

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
    static var tabs: [RootTabs] { allCases }
    static var sidebar: [RootTabs] { allCases }
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
