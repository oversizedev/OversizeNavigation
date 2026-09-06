//
// Copyright © 2026 Alexander Romanov
// LayoutsDestinations.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

enum LayoutsDestinations: Codable, CaseIterable, Hashable, Sendable {
    case navigationLayout
    case listLayout
    case selectableListLayout
    case coverLayout
    case listCoverLayout
    case backConfirmationPushed
    case backConfirmationSheet
}

extension LayoutsDestinations: Identifiable {
    var id: String { "\(self)" }
}

extension LayoutsDestinations: @MainActor NavigationDestination {
    var body: some View {
        switch self {
        case .navigationLayout:
            NavigationLayoutScreen()
        case .listLayout:
            ListLayoutScreen()
        case .selectableListLayout:
            SelectableListLayoutScreen()
        case .coverLayout:
            CoverLayoutScreen()
        case .listCoverLayout:
            ListCoverLayoutScreen()
        case .backConfirmationPushed:
            BackConfirmationScreen(isSheet: false)
        case .backConfirmationSheet:
            BackConfirmationScreen(isSheet: true)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .backConfirmationSheet:
            .managedSheet
        default:
            .push
        }
    }
}

extension LayoutsDestinations {
    /// The catalog is the whole enum: a new layout demo shows up in the list by existing.
    static var catalog: [LayoutsDestinations] { allCases }

    var title: String {
        switch self {
        case .navigationLayout: "NavigationLayout"
        case .listLayout: "NavigationListLayout"
        case .selectableListLayout: "NavigationListLayout + selection"
        case .coverLayout: "NavigationCoverLayout"
        case .listCoverLayout: "NavigationListCoverLayout"
        case .backConfirmationPushed: "Back confirmation, pushed"
        case .backConfirmationSheet: "Back confirmation, sheet"
        }
    }

    var subtitle: String {
        switch self {
        case .navigationLayout: "Scrollable content with a custom background"
        case .listLayout: "Every ListLayoutStyle side by side"
        case .selectableListLayout: "Multiple selection bound to the layout"
        case .coverLayout: "Hero header with static, parallax and pinch"
        case .listCoverLayout: "List with a cover header"
        case .backConfirmationPushed: "Confirm before popping the screen"
        case .backConfirmationSheet: "Confirm before dismissing the sheet"
        }
    }
}
