//
// Copyright © 2026 Alexander Romanov
// DeepLinkUITests.swift, created on 05.09.2026
//

import XCTest

final class DeepLinkUITests: ExampleUITestCase {
    @MainActor
    func testSendSwitchesTabAndPushes() {
        openTab("Flows")
        tapRow("flows.sendHUD")
        assertScreen("HUD")
        assertSelectedTab("Presentation")
    }

    /// A value is consumed by the first handler registered for its type, so a second handler
    /// on the same type answers the first route and silently drops the next one.
    @MainActor
    func testTheSameRouteWorksTwice() {
        openTab("Flows")
        tapRow("flows.routeAbout")
        assertScreen("About")
        assertSelectedTab("Settings")

        openTab("Flows")
        assertScreen("Flows")

        tapRow("flows.routeAbout")
        assertScreen("About")
        assertSelectedTab("Settings")
    }

    /// The split root selects its section through the same `onNavigationReceive` handler the
    /// tab bar uses, and only one of the two roots is ever mounted. In a compact width the
    /// split view collapses into a stack whose root screen hides its back control, so the
    /// sidebar is only reachable where the layout keeps two columns — every Mac window, and an
    /// iPad but not an iPhone.
    @MainActor
    func testRouteWorksUnderTheSplitRoot() throws {
        if isSplitRootByDefault == false {
            openTab("Settings")
            tapRow("settings.toggleRoot")
            assertScreen("Layouts")

            // Only a compact width is a legitimate reason to skip: there the split view
            // collapses and the sidebar is genuinely unreachable. The wait is generous because a
            // skip here is silent — a sidebar that exists but is slow to appear would otherwise
            // read as "iPhone" and quietly retire the test.
            try XCTSkipUnless(
                app.buttons["sidebar.flows"].waitForExistence(timeout: elementTimeout),
                "The sidebar needs a regular width"
            )
        }

        openSidebarSection("flows")
        assertScreen("Flows")

        tapRow("flows.routeAbout")
        assertScreen("About")
    }

    @MainActor
    func testRouteRunsSeveralStepsInOrder() {
        openTab("Flows")
        tapRow("flows.routeDeep")
        assertScreen("Page 3")
    }

    /// Toggling swaps which root is mounted, whichever one the platform started on. The proof is
    /// the same on both: the new root renders a screen and the old root's own control is gone.
    /// Asserting the replacement root's tab control positively would tie the test to how each
    /// platform publishes a `TabView`, which is exactly what `tabControl` cannot promise on a Mac.
    @MainActor
    func testRootLayoutCanBeSwapped() {
        openTab("Settings")
        tapRow("settings.toggleRoot")

        assertScreen("Layouts")

        if isSplitRootByDefault {
            XCTAssertFalse(
                app.buttons["sidebar.settings"].exists,
                "The sidebar stayed mounted after toggling to the tab root"
            )
        } else {
            XCTAssertFalse(
                app.tabBars.buttons["Settings"].exists,
                "The tab bar stayed mounted after toggling to the split root"
            )
        }
    }
}
