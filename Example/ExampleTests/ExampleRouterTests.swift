//
// Copyright © 2026 Alexander Romanov
// ExampleRouterTests.swift, created on 05.09.2026
//

import Testing
@testable import Example

/// A route names a place; the values it expands to are what actually travels through the
/// navigator, so they are what the tests pin down.
@MainActor
struct ExampleRouterTests {
    @Test("The about route switches tab before pushing")
    func aboutRoute() {
        let values = ExampleRoutes.about.values

        #expect(values.count == 2)
        #expect(values[0] as? RootTabs == .settings)
        #expect(values[1] as? SettingsDestinations == .about)
    }

    @Test("The HUD route crosses into another tab")
    func hudRoute() {
        let values = ExampleRoutes.hud.values

        #expect(values.count == 2)
        #expect(values[0] as? RootTabs == .presentation)
        #expect(values[1] as? PresentationDestinations == .hud)
    }

    @Test("A route may need more than one push")
    func deepPageRoute() {
        let values = ExampleRoutes.deepPage.values

        #expect(values.count == 3)
        #expect(values[0] as? RootTabs == .flows)
        #expect(values[1] as? FlowsDestinations == .page(2))
        #expect(values[2] as? FlowsDestinations == .page(3))
    }

    @Test("Every route starts by selecting the tab that owns the screen")
    func everyRouteStartsWithATab() {
        for route in [ExampleRoutes.about, .hud, .deepPage] {
            #expect(route.values.first as? RootTabs != nil)
        }
    }
}
