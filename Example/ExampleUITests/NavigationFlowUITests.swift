//
// Copyright © 2026 Alexander Romanov
// NavigationFlowUITests.swift, created on 05.09.2026
//

import XCTest

final class NavigationFlowUITests: ExampleUITestCase {
    @MainActor
    func testEveryTabIsReachable() throws {
        for title in ["Layouts", "Flows", "Presentation", "Settings"] {
            openTab(title)
            assertScreen(title)
        }
    }

    @MainActor
    func testNavigationLinkPushesAndPops() throws {
        openTab("Flows")
        tapRow("flows.navigate")
        assertScreen("Page 1")

        tapRow("page.push")
        assertScreen("Page 2")

        tapBack(.system)
        assertScreen("Page 1")
    }

    @MainActor
    func testImperativeNavigatePushes() throws {
        openTab("Flows")
        tapRow("flows.navigate")
        assertScreen("Page 1")
    }

    @MainActor
    func testNavigationOpenPushes() throws {
        openTab("Flows")
        tapRow("flows.open")
        assertScreen("Page 1")
    }

    @MainActor
    func testNavigationMovePushes() throws {
        openTab("Flows")
        tapRow("flows.move")
        assertScreen("Page 1")
    }

    @MainActor
    func testNavigationBackPopsProgrammatically() throws {
        openTab("Flows")
        tapRow("flows.navigate")
        assertScreen("Page 1")

        tapRow("page.back")
        assertScreen("Flows")
    }

    @MainActor
    func testCheckpointReturnsFromDeepStack() throws {
        openTab("Flows")
        tapRow("flows.navigate")
        assertScreen("Page 1")

        tapRow("page.push")
        assertScreen("Page 2")

        tapRow("page.push")
        assertScreen("Page 3")

        tapRow("page.checkpoint")
        assertScreen("Flows")
    }

    @MainActor
    func testCheckpointReturnsAValue() throws {
        openTab("Flows")
        tapRow("flows.checkpointResult")
        assertScreen("Return a value")

        tapRow("checkpoint.return")
        assertScreen("Flows")

        let result = row("flows.checkpointResult")
        XCTAssertTrue(result.label.contains("Last result: 42"))
    }

    @MainActor
    func testManagedSheetDismisses() throws {
        openTab("Flows")
        tapRow("flows.sheet")
        assertScreen("Managed sheet")

        tapRow("sheet.dismiss")
        assertScreen("Flows")
    }

    @MainActor
    func testManagedSheetPushesInsideItsOwnStack() throws {
        openTab("Flows")
        tapRow("flows.sheet")
        assertScreen("Managed sheet")

        tapRow("sheet.push")
        assertScreen("Page 1")

        tapBack(.system)
        assertScreen("Managed sheet")
    }

    @MainActor
    func testManagedCoverDismisses() throws {
        openTab("Flows")
        tapRow("flows.cover")
        assertScreen("Managed cover")

        tapRow("cover.dismiss")
        assertScreen("Flows")
    }

    @MainActor
    func testLockedScreenSurvivesDismissAny() throws {
        openTab("Flows")
        tapRow("flows.locked")
        assertScreen("Locked")

        tapRow("locked.dismissAny")
        assertScreen("Locked")

        tapRow("locked.back")
        assertScreen("Flows")
    }
}
