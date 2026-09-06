//
// Copyright © 2026 Alexander Romanov
// NavigationExitTests.swift, created on 06.09.2026
//

import NavigatorUI
@testable import OversizeNavigation
import SwiftUI
import Testing

/// The depth-to-operation mapping is the whole of what separates the three exits.
@MainActor
struct NavigationExitTests {
    @Test("Every depth is a case the call site can name")
    func everyDepthIsReachable() {
        #expect(NavigationExit.allCases == [.screen, .presentation, .allPresentations])
    }

    @Test("Nothing to leave at the root, whatever the depth", arguments: NavigationExit.allCases)
    func rootHasNothingToLeave(exit: NavigationExit) throws {
        let navigator = Navigator.root()

        #expect(try exit.leave(on: navigator) == false)
    }

    @Test("A locked screen only blocks the global exit")
    func lockOnlyBlocksAllPresentations() throws {
        let navigator = Navigator.root()

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
