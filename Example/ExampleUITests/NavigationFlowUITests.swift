//
// Copyright © 2026 Alexander Romanov
// NavigationFlowUITests.swift, created on 05.09.2026
//

import XCTest

final class NavigationFlowUITests: ExampleUITestCase {
    @MainActor
    func testEveryTabIsReachable() {
        for title in ["Layouts", "Flows", "Presentation", "Settings"] {
            openTab(title)
            assertScreen(title)
        }
    }

    @MainActor
    func testNavigationMovePushes() {
        openTab("Flows")
        tapRow("flows.move")
        assertScreen("Page 1")
        assertSelectedTab("Flows")
    }

    /// A stack builds the same destination twice when the container decomposes the link, and
    /// the second copy hides the first — so the depth is what the assertion has to read.
    /// Also covers the plain push-and-pop round trip through `NavigationLink(to:)`.
    @MainActor
    func testNavigationLinkPushesOnce() {
        openTab("Flows")
        tapRow("flows.open")
        assertScreen("Page 1")

        tapRow("page.push")
        assertScreen("Page 2")

        XCTAssertTrue(app.staticTexts["Pushed 2 deep"].waitForExistence(timeout: 5))

        tapBack(.system)
        assertScreen("Page 1")
    }

    @MainActor
    func testNavigationOpenFromAPushedScreenStaysOnItsStack() {
        openTab("Flows")
        tapRow("flows.open")
        assertScreen("Page 1")

        tapRow("page.open")
        assertScreen("Page 2")
        assertSelectedTab("Flows")

        XCTAssertTrue(app.staticTexts["Pushed 2 deep"].waitForExistence(timeout: 5))
    }

    /// `navigationMove` broadcasts, and the first registered handler answers — from a pushed
    /// screen that used to be a stack nobody was looking at.
    @MainActor
    func testNavigationMoveFromAPushedScreenStaysOnItsStack() {
        openTab("Flows")
        tapRow("flows.open")
        assertScreen("Page 1")

        tapRow("page.move")
        assertScreen("Page 2")
        assertSelectedTab("Flows")
    }

    /// A pushed screen asking for a sheet used to present only after the next navigation
    /// event, so the wait is deliberately short.
    @MainActor
    func testSheetPresentsFromAPushedScreenWithoutDelay() {
        openTab("Flows")
        tapRow("flows.open")
        assertScreen("Page 1")

        tapRow("page.sheet")
        XCTAssertTrue(
            app.navigationBars["Managed sheet"].waitForExistence(timeout: 3),
            "The sheet did not present while the screen that asked for it was still on screen"
        )

        tapRow("sheet.dismiss")
        assertScreen("Page 1")
    }

    /// Popping and publishing a HUD in one state update used to leave the screen on display
    /// while the HUD was presented.
    @MainActor
    func testPopWithAHUDLeavesImmediately() {
        openTab("Flows")
        tapRow("flows.open")
        assertScreen("Page 1")

        tapRow("page.backWithHUD")
        XCTAssertTrue(
            app.navigationBars["Flows"].waitForExistence(timeout: 3),
            "The screen stayed on display after the pop was requested"
        )
        XCTAssertTrue(app.staticTexts["Deleted"].exists)
    }

    /// A tab whose stack is nested inside another one reads as presented, and the layouts
    /// answer that by installing a close button over the tab root.
    @MainActor
    func testTabRootsAreStackRoots() {
        for title in ["Layouts", "Flows", "Presentation", "Settings"] {
            openTab(title)
            assertScreen(title)

            for control in [BackControl.system, .confirmation, .close] {
                XCTAssertFalse(
                    app.buttons[control.rawValue].exists,
                    "\(title) shows a \(control) control at the root of its tab"
                )
            }
        }
    }

    @MainActor
    func testNavigationBackPopsProgrammatically() {
        openTab("Flows")
        tapRow("flows.open")
        assertScreen("Page 1")

        tapRow("page.back")
        assertScreen("Flows")
    }

    @MainActor
    func testCheckpointReturnsFromDeepStack() {
        openTab("Flows")
        tapRow("flows.open")
        assertScreen("Page 1")

        tapRow("page.push")
        assertScreen("Page 2")

        tapRow("page.push")
        assertScreen("Page 3")

        tapRow("page.checkpoint")
        assertScreen("Flows")
    }

    @MainActor
    func testCheckpointReturnsAValue() {
        openTab("Flows")
        tapRow("flows.checkpointResult")
        assertScreen("Return a value")

        tapRow("checkpoint.return")
        assertScreen("Flows")

        let result = row("flows.checkpointResult")
        XCTAssertTrue(result.label.contains("Last result: 42"))
    }

    @MainActor
    func testManagedSheetDismisses() {
        openTab("Flows")
        tapRow("flows.sheet")
        assertScreen("Managed sheet")

        tapRow("sheet.dismiss")
        assertScreen("Flows")
    }

    @MainActor
    func testManagedSheetPushesInsideItsOwnStack() {
        openTab("Flows")
        tapRow("flows.sheet")
        assertScreen("Managed sheet")

        tapRow("sheet.push")
        assertScreen("Page 1")

        tapBack(.system)
        assertScreen("Managed sheet")
    }

    @MainActor
    func testManagedCoverDismisses() {
        openTab("Flows")
        tapRow("flows.cover")
        assertScreen("Managed cover")

        tapRow("cover.dismiss")
        assertScreen("Flows")
    }

    @MainActor
    func testLockedScreenSurvivesDismissAny() {
        openTab("Flows")
        tapRow("flows.locked")
        assertScreen("Locked")

        tapRow("locked.dismissAny")
        assertScreen("Locked")

        tapRow("locked.back")
        assertScreen("Flows")
    }
}
