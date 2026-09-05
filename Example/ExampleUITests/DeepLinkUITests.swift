//
// Copyright © 2026 Alexander Romanov
// DeepLinkUITests.swift, created on 05.09.2026
//

import XCTest

final class DeepLinkUITests: ExampleUITestCase {
    @MainActor
    func testSendSwitchesTabAndPushes() throws {
        openTab("Flows")
        tapRow("flows.sendHUD")
        assertScreen("HUD")
    }

    @MainActor
    func testRouteOpensAboutInAnotherTab() throws {
        openTab("Flows")
        tapRow("flows.routeAbout")
        assertScreen("About")
    }

    @MainActor
    func testRouteRunsSeveralStepsInOrder() throws {
        openTab("Flows")
        tapRow("flows.routeDeep")
        assertScreen("Page 3")
    }

    @MainActor
    func testRootLayoutCanBeSwapped() throws {
        openTab("Settings")
        tapRow("settings.toggleRoot")

        XCTAssertTrue(app.navigationBars["Layouts"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.tabBars.buttons["Settings"].exists)
    }
}
