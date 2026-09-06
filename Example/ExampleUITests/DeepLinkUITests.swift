//
// Copyright © 2026 Alexander Romanov
// DeepLinkUITests.swift, created on 05.09.2026
//

import UIKit
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
    /// sidebar is only reachable where the layout keeps two columns.
    @MainActor
    func testRouteWorksUnderTheSplitRoot() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad, "The sidebar needs a regular width")

        openTab("Settings")
        tapRow("settings.toggleRoot")
        XCTAssertTrue(app.navigationBars["Layouts"].waitForExistence(timeout: 10))

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

    @MainActor
    func testRootLayoutCanBeSwapped() {
        openTab("Settings")
        tapRow("settings.toggleRoot")

        XCTAssertTrue(app.navigationBars["Layouts"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.tabBars.buttons["Settings"].exists)
    }
}
