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
    func testAlertConfirmationRunsItsAction() throws {
        #if os(macOS)
            // macOS renders a legacy `Alert` as a sheet whose buttons carry no geometry at all
            // ({{inf, inf}, {0, 0}}), and the destructive role deliberately has no keyboard
            // equivalent — XCUITest physically cannot press it. The alert's presence and its
            // cancel path are still covered by `testAlertCancellationKeepsTheState`.
            throw XCTSkip("macOS publishes legacy Alert buttons without geometry")
        #else
            openTab("Presentation")
            tapRow("presentation.alerts")
            assertScreen("Alerts")

            tapRow("alert.discard")

            tapAlertButton("Discard")

            XCTAssertTrue(
                staticText("discard").waitForExistence(timeout: elementTimeout / 2),
                "The discard action never ran. \(alertDiagnostics())"
            )
        #endif
    }

    @MainActor
    func testAlertCancellationKeepsTheState() {
        openTab("Presentation")
        tapRow("presentation.alerts")
        assertScreen("Alerts")

        tapRow("alert.discard")

        tapAlertButton("Cancel", cancels: true)

        XCTAssertTrue(staticText("None").waitForExistence(timeout: elementTimeout / 2))
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
    ///
    /// Which one a Mac publishes is only knowable once the picker is on screen, so both are
    /// polled: a screen whose title has appeared before its controls have publishes neither,
    /// and committing to one of them from that snapshot waits out the timeout on a query that
    /// will never resolve.
    @MainActor
    private func statePicker() -> XCUIElement {
        #if os(macOS)
            let deadline = Date().addingTimeInterval(elementTimeout)
            repeat {
                let radioGroup = app.radioGroups["loadingState.picker"]
                if radioGroup.exists {
                    return radioGroup
                }
                let segmented = app.segmentedControls["loadingState.picker"]
                if segmented.exists {
                    return segmented
                }
                Thread.sleep(forTimeInterval: 0.25)
            } while Date() < deadline

            return app.radioGroups["loadingState.picker"]
        #else
            return app.segmentedControls["loadingState.picker"]
        #endif
    }

    /// A radio group exposes its choices as radio buttons rather than buttons, so the element
    /// type has to follow whichever container the platform published — polled for the same
    /// reason the container itself is.
    @MainActor
    private func pickerOption(_ picker: XCUIElement, _ title: String) -> XCUIElement {
        #if os(macOS)
            let deadline = Date().addingTimeInterval(elementTimeout)
            repeat {
                let radioButton = picker.radioButtons[title]
                if radioButton.exists {
                    return radioButton
                }
                let button = picker.buttons[title]
                if button.exists {
                    return button
                }
                Thread.sleep(forTimeInterval: 0.25)
            } while Date() < deadline

            return picker.radioButtons[title]
        #else
            return picker.buttons[title]
        #endif
    }
}
