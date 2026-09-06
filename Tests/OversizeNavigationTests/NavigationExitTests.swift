//
// Copyright © 2026 Alexander Romanov
// NavigationExitTests.swift, created on 06.09.2026
//

import NavigatorUI
import SwiftUI
import Testing
@testable import OversizeNavigation

/// Leaving a screen was three modifiers whose names hid how far each one went. They are now one
/// modifier over ``NavigationExit``, so what distinguishes the depths is this mapping alone.
@MainActor
struct NavigationExitTests {
    @Test("Every depth is a case the call site can name")
    func everyDepthIsReachable() {
        #expect(NavigationExit.allCases == [.screen, .presentation, .allPresentations])
    }

    /// A root navigator has nothing pushed and is not presented, so every depth agrees there is
    /// nothing to leave. This is the baseline the cases diverge from once a stack has depth.
    @Test("Nothing to leave at the root, whatever the depth", arguments: NavigationExit.allCases)
    func rootHasNothingToLeave(exit: NavigationExit) throws {
        let navigator = Navigator.root()

        #expect(try exit.leave(on: navigator) == false)
    }

    @Test("A locked screen only blocks the global exit")
    func lockOnlyBlocksAllPresentations() throws {
        let navigator = Navigator.root()

        // `back` and `presentation` never consult the lock, so they stay non-throwing.
        #expect(try NavigationExit.screen.leave(on: navigator) == false)
        #expect(try NavigationExit.presentation.leave(on: navigator) == false)
        #expect(navigator.isNavigationLocked == false)
        #expect(try NavigationExit.allPresentations.leave(on: navigator) == false)
    }

    @Test("The modifier defaults to leaving one screen")
    func defaultsToOneScreen() {
        let view = Text("Screen").navigationBack(.constant(false))

        #expect(String(describing: type(of: view)).contains("ModifiedContent"))
    }

    @Test("The modifier takes a depth and a completion")
    func takesADepthAndCompletion() {
        let view = Text("Screen")
            .navigationBack(.constant(false), to: .allPresentations) { _ in }

        #expect(String(describing: type(of: view)).contains("ModifiedContent"))
    }
}
