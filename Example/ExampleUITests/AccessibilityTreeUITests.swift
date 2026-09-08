//
// Copyright © 2026 Alexander Romanov
// AccessibilityTreeUITests.swift, created on 05.09.2026
//

import XCTest

/// `presentationHUDRoot()` wraps the whole app in a `ZStack`, and a modifier applied over that
/// wrapper can stop the accessibility tree from being published — the app still renders, but
/// XCUITest sees nested containers with no text and no buttons. Every other test in this target
/// depends on the tree, so it is asserted on its own.
final class AccessibilityTreeUITests: ExampleUITestCase {
    @MainActor
    func testTheAppPublishesAnAccessibilityTree() {
        XCTAssertTrue(tabControl("Layouts").waitForExistence(timeout: elementTimeout))
        XCTAssertGreaterThan(app.staticTexts.count, 0, "The app published no text")
        XCTAssertGreaterThan(app.buttons.count, 0, "The app published no controls")
    }

    @MainActor
    func testTheTreeSurvivesAPresentedHUD() {
        openTab("Presentation")
        tapRow("presentation.hud")
        assertScreen("HUD")

        tapRow("hud.success")
        XCTAssertTrue(app.staticTexts["Success"].waitForExistence(timeout: elementTimeout / 2))

        // The row that raised the HUD is on screen on every device; `hud.clear` is below the fold on an iPhone.
        XCTAssertTrue(app.buttons["hud.success"].exists, "The HUD overlay hid the screen underneath it")
        XCTAssertGreaterThan(app.staticTexts.count, 1)
    }
}
