//
// Copyright © 2026 Alexander Romanov
// SettingsDestinations.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

enum SettingsDestinations: Codable, Hashable, Sendable {
    case about
}

extension SettingsDestinations: Identifiable {
    var id: String {
        "\(self)"
    }
}

extension SettingsDestinations: @MainActor NavigationDestination {
    var body: some View {
        switch self {
        case .about:
            AboutScreen()
        }
    }
}
