//
// Copyright © 2026 Alexander Romanov
// FlowsDestinations.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import SwiftUI

enum FlowsDestinations: Codable, Hashable, Sendable {
    case page(Int)
    case sheet
    case cover
    case checkpointResult
    case locked
}

extension FlowsDestinations: Identifiable {
    var id: String {
        "\(self)"
    }
}

extension FlowsDestinations: @MainActor NavigationDestination {
    var body: some View {
        switch self {
        case let .page(number):
            FlowPageScreen(number: number)
        case .sheet:
            ManagedSheetScreen()
        case .cover:
            ManagedCoverScreen()
        case .checkpointResult:
            CheckpointResultScreen()
        case .locked:
            LockedScreen()
        }
    }

    var method: NavigationMethod {
        switch self {
        case .sheet:
            .managedSheet
        case .cover:
            // NavigatorUI has no full screen cover on macOS, so asking for one there presents
            // nothing at all.
            .platformManagedCover
        default:
            .push
        }
    }
}
