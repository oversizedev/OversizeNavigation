//
// Copyright © 2026 Alexander Romanov
// NavigationExit.swift, created on 06.09.2026
//

import NavigatorUI

/// How far a screen leaves when ``SwiftUI/View/navigationBack(_:to:completion:)`` fires.
///
/// The three cases were three separate modifiers, which read as interchangeable at a call site —
/// a screen sitting at the root of a sheet leaves identically under ``screen`` and
/// ``presentation``, and only the depth tells them apart. Naming the depth here makes the choice
/// explicit instead of hiding it in a modifier name.
public enum NavigationExit: Sendable, Hashable, CaseIterable {
    /// Pops one screen. A screen already at the root of a presentation dismisses that
    /// presentation instead, so this always leaves something.
    case screen

    /// Dismisses the presentation this screen lives in, however deep inside it the screen sits.
    /// Use it when a sheet has to close as a whole rather than step back one screen.
    case presentation

    /// Dismisses every presentation in the navigation tree, returning to the root.
    /// A screen marked ``SwiftUI/View/navigationLocked()`` blocks this and the completion
    /// receives the failure.
    case allPresentations
}

extension NavigationExit {
    /// Performs the depth this case names and reports whether anything was left.
    ///
    /// The mapping lives here rather than inside the modifier so it can be asserted directly —
    /// it is the whole of what distinguishes the three cases.
    @MainActor
    func leave(on navigator: Navigator) throws -> Bool {
        switch self {
        case .screen: navigator.back()
        case .presentation: navigator.dismiss()
        case .allPresentations: try navigator.dismissAny()
        }
    }
}
