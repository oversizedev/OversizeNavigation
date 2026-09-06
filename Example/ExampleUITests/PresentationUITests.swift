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
        XCTAssertTrue(hud.waitForExistence(timeout: elementTimeout / 2))

        let disappeared = NSPredicate(format: "exists == false")
        expectation(for: disappeared, evaluatedWith: hud)
        waitForExpectations(timeout: elementTimeout)
    }

    @MainActor
    func testHUDStackKeepsOnlyThree() {
        openTab("Presentation")
        tapRow("presentation.hud")
        assertScreen("HUD")

        tapRow("hud.stack")

        XCTAssertTrue(app.staticTexts["HUD 5"].waitForExistence(timeout: elementTimeout / 2))
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
        XCTAssertTrue(app.staticTexts["HUD 5"].waitForExistence(timeout: elementTimeout / 2))

        tapRow("hud.clear")

        let cleared = NSPredicate(format: "exists == false")
        expectation(for: cleared, evaluatedWith: app.staticTexts["HUD 5"])
        waitForExpectations(timeout: elementTimeout)
    }

    @MainActor
    func testAlertConfirmationRunsItsAction() {
        openTab("Presentation")
        tapRow("presentation.alerts")
        assertScreen("Alerts")

        tapRow("alert.discard")

        let confirm = app.alerts.buttons["Discard"]
        XCTAssertTrue(confirm.waitForExistence(timeout: elementTimeout / 2))
        confirm.tap()

        XCTAssertTrue(app.staticTexts["discard"].waitForExistence(timeout: elementTimeout / 2))
    }

    @MainActor
    func testAlertCancellationKeepsTheState() {
        openTab("Presentation")
        tapRow("presentation.alerts")
        assertScreen("Alerts")

        tapRow("alert.discard")

        let cancel = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: elementTimeout / 2))
        cancel.tap()

        XCTAssertTrue(app.staticTexts["None"].waitForExistence(timeout: elementTimeout / 2))
    }

    /// The demo starts in the empty state, so its overlay is already on screen; the pickers that
    /// drive the demo have to stay reachable underneath it.
    @MainActor
    func testLoadingStateControlsStayReachable() {
        openTab("Presentation")
        tapRow("presentation.loadingStates")
        assertScreen("Loading states")

        let picker = statePicker()
        XCTAssertTrue(picker.waitForExistence(timeout: elementTimeout), "The overlay covered the state picker")

        pickerOption(picker, "Result").tap()
        XCTAssertTrue(app.staticTexts["Item 1"].waitForExistence(timeout: elementTimeout / 2))
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

    /// A radio group exposes its choices as radio buttons rather than buttons, so the element
    /// type has to follow whichever container the platform published.
    @MainActor
    private func pickerOption(_ picker: XCUIElement, _ title: String) -> XCUIElement {
        #if os(macOS)
            let radioButton = picker.radioButtons[title]
            return radioButton.exists ? radioButton : picker.buttons[title]
        #else
            return picker.buttons[title]
        #endif
    }
}
