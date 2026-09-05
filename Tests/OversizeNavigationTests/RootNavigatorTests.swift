//
// Copyright © 2026 Alexander Romanov
// RootNavigatorTests.swift, created on 05.09.2026
//

import NavigatorUI
import Testing
@testable import OversizeNavigation

@MainActor
struct RootNavigatorTests {
    @Test("Debug builds log navigation events")
    func defaultVerbosity() {
        #if DEBUG
            #expect(Navigator.defaultVerbosity == .info)
        #else
            #expect(Navigator.defaultVerbosity == .warning)
        #endif
    }

    @Test("A freshly built root navigator has nothing on screen")
    func rootStartsEmpty() {
        let navigator = Navigator.root(restorationKey: "Example")

        #expect(navigator.count == 0)
        #expect(navigator.isPresented == false)
        #expect(navigator.isNavigationLocked == false)
    }

    @Test("The root navigator is the root of its own tree")
    func rootOwnsItsTree() {
        let navigator = Navigator.root()

        #expect(navigator.root.id == navigator.id)
    }
}
