//
// Copyright © 2026 Alexander Romanov
// NavigationExit.swift, created on 06.09.2026
//

import NavigatorUI

/// How far a screen leaves when ``SwiftUI/View/navigationBack(_:to:completion:)`` fires.
public enum NavigationExit: Sendable, Hashable, CaseIterable {
    /// Pops one screen, or dismisses the presentation when already at its root.
    case screen

    /// Dismisses the presentation this screen lives in, however deep inside it the screen sits.
    case presentation

    /// Dismisses every presentation in the tree. A ``SwiftUI/View/navigationLocked()`` screen blocks it.
    case allPresentations
}

extension NavigationExit {
    /// Performs the depth this case names and reports whether anything was left.
    @MainActor
    func leave(on navigator: Navigator) throws -> Bool {
        switch self {
        case .screen: navigator.back()
        case .presentation: navigator.dismiss()
        case .allPresentations: try navigator.dismissAny()
        }
    }
}
