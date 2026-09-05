//
// Copyright © 2026 Alexander Romanov
// NavigationModifierSignatureTests.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI
import Testing
@testable import OversizeNavigation

/// A feature package declares its destinations, while the `NavigationDestination` conformance
/// is added in the app target. Inside that package the compiler only sees a `Hashable` value,
/// so a modifier constrained to `NavigationDestination` cannot be called there at all — the
/// constraint is part of the contract and is pinned by types rather than by behaviour.
@MainActor
struct NavigationModifierSignatureTests {
    private struct PlainDestination: Hashable {
        let id: Int
    }

    private struct ConformingDestination: Hashable, @MainActor NavigationDestination {
        var body: some View { Text("Destination") }
    }

    @Test("navigationOpen accepts a value that is only Hashable in this module")
    func openTakesAPlainHashable() {
        let view = Text("Screen").navigationOpen(.constant(PlainDestination?.none))

        #expect(String(describing: type(of: view)).contains("ModifiedContent"))
    }

    @Test("navigationOpen still accepts a full destination")
    func openTakesADestination() {
        let view = Text("Screen").navigationOpen(.constant(ConformingDestination?.none))

        #expect(String(describing: type(of: view)).contains("ModifiedContent"))
    }

    @Test("navigationMove accepts a value that is only Hashable in this module")
    func moveTakesAPlainHashable() {
        let view = Text("Screen").navigationMove(.constant(PlainDestination?.none))

        #expect(String(describing: type(of: view)).contains("ModifiedContent"))
    }

    /// A deep link mixes types on purpose: a tab value first, then the destination it pushes.
    @Test("navigationMove takes an ordered list of unrelated values")
    func moveTakesValuesOfDifferentTypes() {
        let values: [AnyHashable] = [PlainDestination(id: 1), ConformingDestination()]
        let view = Text("Screen").navigationMove(values: .constant(values))

        #expect(String(describing: type(of: view)).contains("ModifiedContent"))
    }
}
