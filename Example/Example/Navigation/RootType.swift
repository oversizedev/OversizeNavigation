//
// Copyright © 2026 Alexander Romanov
// RootType.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

enum RootType: Int, Codable, Sendable {
    case tabbed
    case split

    var toggled: RootType {
        self == .tabbed ? .split : .tabbed
    }
}

/// Sent through the navigator to swap the root layout from anywhere in the tree.
struct ToggleRootType: Hashable, Sendable {}

extension RootType: Identifiable {
    var id: Int { rawValue }
}

extension RootType: @MainActor NavigationDestination {
    var body: some View {
        switch self {
        case .tabbed:
            RootTabView()
        case .split:
            RootSplitView()
        }
    }
}
