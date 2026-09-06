//
// Copyright © 2026 Alexander Romanov
// PresentationDestinations.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

enum PresentationDestinations: Codable, Hashable, Sendable {
    case hud
    case alerts
    case loadingStates
}

extension PresentationDestinations: Identifiable {
    var id: String {
        "\(self)"
    }
}

extension PresentationDestinations: @MainActor NavigationDestination {
    var body: some View {
        switch self {
        case .hud:
            HUDScreen()
        case .alerts:
            AlertScreen()
        case .loadingStates:
            LoadingStateScreen()
        }
    }
}

extension PresentationDestinations {
    static var catalog: [PresentationDestinations] {
        [.hud, .alerts, .loadingStates]
    }

    var title: String {
        switch self {
        case .hud: "HUD"
        case .alerts: "Alerts"
        case .loadingStates: "Loading states"
        }
    }

    var subtitle: String {
        switch self {
        case .hud: "Every HUD case and the three-item stack"
        case .alerts: "Every AppAlert case"
        case .loadingStates: "contentUnavailable and errorState"
        }
    }
}
