//
// Copyright © 2026 Alexander Romanov
// PresentationUITests.swift, created on 05.09.2026
//

import XCTest

final class PresentationUITests: ExampleUITestCase {
    @MainActor
    func testHUDAppearsAndDismissesItself() throws {
        openTab("Presentation")
        tapRow("presentation.hud")
        assertScreen("HUD")

        tapRow("hud.success")

        let hud = app.staticTexts["Success"]
        XCTAssertTrue(hud.waitForExistence(timeout: 5))

        let disappeared = NSPredicate(format: "exists == false")
        expectation(for: disappeared, evaluatedWith: hud)
        waitForExpectations(timeout: 15)
    }

    @MainActor
    func testHUDStackKeepsOnlyThree() throws {
        openTab("Presentation")
        tapRow("presentation.hud")
        assertScreen("HUD")

        tapRow("hud.stack")

        XCTAssertTrue(app.staticTexts["HUD 5"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["HUD 4"].exists)
        XCTAssertTrue(app.staticTexts["HUD 3"].exists)
        XCTAssertFalse(app.staticTexts["HUD 1"].exists)
    }

    @MainActor
    func testHUDStackCanBeCleared() throws {
        openTab("Presentation")
        tapRow("presentation.hud")
        assertScreen("HUD")

        tapRow("hud.stack")
        XCTAssertTrue(app.staticTexts["HUD 5"].waitForExistence(timeout: 5))

        tapRow("hud.clear")

        let cleared = NSPredicate(format: "exists == false")
        expectation(for: cleared, evaluatedWith: app.staticTexts["HUD 5"])
        waitForExpectations(timeout: 10)
    }

    @MainActor
    func testAlertConfirmationRunsItsAction() throws {
        openTab("Presentation")
        tapRow("presentation.alerts")
        assertScreen("Alerts")

        tapRow("alert.discard")

        let confirm = app.alerts.buttons["Discard"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()

        XCTAssertTrue(app.staticTexts["discard"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAlertCancellationKeepsTheState() throws {
        openTab("Presentation")
        tapRow("presentation.alerts")
        assertScreen("Alerts")

        tapRow("alert.discard")

        let cancel = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 5))
        cancel.tap()

        XCTAssertTrue(app.staticTexts["None"].waitForExistence(timeout: 5))
    }
}
