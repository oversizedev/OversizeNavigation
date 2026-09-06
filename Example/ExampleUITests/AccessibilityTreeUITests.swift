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
    func testTheAppPublishesAnAccessibilityTree() throws {
        XCTAssertTrue(tabControl("Layouts").waitForExistence(timeout: 10))
        XCTAssertGreaterThan(app.staticTexts.count, 0, "The app published no text")
        XCTAssertGreaterThan(app.buttons.count, 0, "The app published no controls")
    }

    @MainActor
    func testTheTreeSurvivesAPresentedHUD() throws {
        openTab("Presentation")
        tapRow("presentation.hud")
        assertScreen("HUD")

        tapRow("hud.success")
        XCTAssertTrue(app.staticTexts["Success"].waitForExistence(timeout: 5))

        // Assert on the row that raised the HUD: it sits at the top of the first section and is
        // therefore on screen on every device. `hud.clear` is in the second section, below the
        // fold on an iPhone, so a `List` never builds it — its absence says nothing about the
        // overlay and made this test pass on iPad while failing on iPhone.
        XCTAssertTrue(app.buttons["hud.success"].exists, "The HUD overlay hid the screen underneath it")
        XCTAssertGreaterThan(app.staticTexts.count, 1)
    }
}
