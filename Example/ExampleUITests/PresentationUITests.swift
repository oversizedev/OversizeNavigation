//
// Copyright © 2026 Alexander Romanov
// PresentationUITests.swift, created on 05.09.2026
//

import XCTest

final class PresentationUITests: ExampleUITestCase {
    @MainActor
    func testHUDAppearsAndDismissesItself() {
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
    func testHUDStackKeepsOnlyThree() {
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
    func testHUDStackCanBeCleared() {
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
    func testAlertConfirmationRunsItsAction() {
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
    func testAlertCancellationKeepsTheState() {
        openTab("Presentation")
        tapRow("presentation.alerts")
        assertScreen("Alerts")

        tapRow("alert.discard")

        let cancel = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 5))
        cancel.tap()

        XCTAssertTrue(app.staticTexts["None"].waitForExistence(timeout: 5))
    }

    /// The demo starts in the empty state, so its overlay is already on screen; the pickers that
    /// drive the demo have to stay reachable underneath it.
    @MainActor
    func testLoadingStateControlsStayReachable() {
        openTab("Presentation")
        tapRow("presentation.loadingStates")
        assertScreen("Loading states")

        let picker = statePicker()
        XCTAssertTrue(picker.waitForExistence(timeout: 10), "The overlay covered the state picker")

        picker.buttons["Result"].tap()
        XCTAssertTrue(app.staticTexts["Item 1"].waitForExistence(timeout: 5))
    }

    /// A segmented picker is a segmented control on iOS and a radio group on a Mac.
    @MainActor
    private func statePicker() -> XCUIElement {
        #if os(macOS)
            let radioGroup = app.radioGroups["loadingState.picker"]
            return radioGroup.exists ? radioGroup : app.segmentedControls["loadingState.picker"]
        #else
            return app.segmentedControls["loadingState.picker"]
        #endif
    }
}
