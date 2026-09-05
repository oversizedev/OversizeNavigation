//
// Copyright © 2026 Alexander Romanov
// ExampleUITestCase.swift, created on 05.09.2026
//

import XCTest

@MainActor
class ExampleUITestCase: XCTestCase {
    /// The layouts install their own control only where the package documents one: the system
    /// button stays in place on an ordinary push.
    enum BackControl: String {
        /// The button SwiftUI provides for a pushed screen.
        case system = "BackButton"
        /// The chevron a layout installs when a back confirmation is set.
        case confirmation = "chevron.left"
        /// The cross a layout installs at the root of a presentation.
        case close = "xmark"
    }

    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ExampleUITesting"]
        app.launch()
    }

    func openTab(_ title: String, file: StaticString = #filePath, line: UInt = #line) {
        let tab = app.tabBars.buttons[title]
        XCTAssertTrue(tab.waitForExistence(timeout: 10), "Tab \(title) is missing", file: file, line: line)
        tab.tap()
    }

    /// Rows below the fold are not created until the list scrolls to them.
    @discardableResult
    func row(_ identifier: String, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        let element = app.buttons[identifier]
        _ = element.waitForExistence(timeout: 5)

        var attempts = 0
        while element.exists == false || element.isHittable == false, attempts < 10 {
            app.swipeUp()
            attempts += 1
        }

        XCTAssertTrue(element.isHittable, "Row \(identifier) never became hittable", file: file, line: line)
        return element
    }

    func tapRow(_ identifier: String, file: StaticString = #filePath, line: UInt = #line) {
        row(identifier, file: file, line: line).tap()
    }

    func assertScreen(_ title: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(
            app.navigationBars[title].waitForExistence(timeout: 10),
            "Expected to be on \(title)",
            file: file,
            line: line
        )
    }

    func tapBack(_ control: BackControl, file: StaticString = #filePath, line: UInt = #line) {
        let button = app.buttons[control.rawValue]
        XCTAssertTrue(
            button.waitForExistence(timeout: 10),
            "No \(control) back control on screen",
            file: file,
            line: line
        )
        button.tap()
    }

    func tapDialogButton(_ title: String, file: StaticString = #filePath, line: UInt = #line) {
        let button = app.buttons[title]
        XCTAssertTrue(button.waitForExistence(timeout: 10), "No \(title) button", file: file, line: line)
        button.tap()
    }

    /// iOS renders the cancel role of a confirmation dialog as the region outside it.
    func dismissDialog(file: StaticString = #filePath, line: UInt = #line) {
        let region = app.otherElements["PopoverDismissRegion"]
        XCTAssertTrue(region.waitForExistence(timeout: 10), "No dialog on screen", file: file, line: line)
        region.tap()
    }
}
