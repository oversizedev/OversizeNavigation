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

    /// The same four sections reach the screen through three different controls: a tab bar in a
    /// compact width, a tab strip at the top on iPad, and a sidebar under the split root.
    func openTab(_ title: String, file: StaticString = #filePath, line: UInt = #line) {
        let control = tabControl(title)
        XCTAssertTrue(
            control.waitForExistence(timeout: 10),
            "No control opens \(title) in this layout",
            file: file,
            line: line
        )
        control.tap()
    }

    /// The control that selects a section, whichever root is mounted.
    func tabControl(_ title: String) -> XCUIElement {
        let tab = app.tabBars.buttons[title]
        if tab.exists { return tab }

        let sidebar = app.buttons["sidebar.\(title.lowercased())"]
        if sidebar.exists { return sidebar }

        return app.buttons.matching(NSPredicate(format: "label == %@", title)).firstMatch
    }

    /// Rows below the fold are not created until the list scrolls to them. A row that ends up
    /// underneath the tab bar still reports `isHittable`, and tapping it selects a tab instead of
    /// running the row, so it has to be scrolled clear of the bar as well.
    @discardableResult
    func row(_ identifier: String, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        let element = app.buttons[identifier]
        _ = element.waitForExistence(timeout: 5)

        var attempts = 0
        while element.exists == false || element.isHittable == false || isCoveredByTabBar(element), attempts < 10 {
            app.swipeUp()
            attempts += 1
        }

        XCTAssertTrue(element.isHittable, "Row \(identifier) never became hittable", file: file, line: line)
        XCTAssertFalse(
            isCoveredByTabBar(element),
            "Row \(identifier) stayed underneath the tab bar",
            file: file,
            line: line
        )
        return element
    }

    /// Only a bar sitting at the bottom of the window can swallow a tap meant for a row; the
    /// iPad tab strip lives at the top and covers nothing.
    private func isCoveredByTabBar(_ element: XCUIElement) -> Bool {
        let tabBar = app.tabBars.firstMatch
        guard element.exists, tabBar.exists else { return false }
        guard tabBar.frame.minY > app.frame.midY else { return false }

        return element.frame.maxY > tabBar.frame.minY
    }

    func tapRow(_ identifier: String, file: StaticString = #filePath, line: UInt = #line) {
        row(identifier, file: file, line: line).tap()
    }

    /// A stack that misroutes a push renders it in a tab nobody is looking at, so the
    /// destination alone does not prove the navigation stayed where it started.
    func assertSelectedTab(_ title: String, file: StaticString = #filePath, line: UInt = #line) {
        let control = tabControl(title)
        XCTAssertTrue(
            control.waitForExistence(timeout: 10),
            "No control opens \(title) in this layout",
            file: file,
            line: line
        )
        XCTAssertTrue(control.isSelected, "Expected \(title) to stay selected", file: file, line: line)
    }

    /// The split root replaces the tab bar with a sidebar, which collapses into a stack in a
    /// compact width — there the sidebar is only reachable after popping the detail column.
    func openSidebarSection(_ tab: String, file: StaticString = #filePath, line: UInt = #line) {
        let section = app.buttons["sidebar.\(tab)"]

        if section.waitForExistence(timeout: 5) == false {
            let back = app.navigationBars.buttons.firstMatch
            if back.exists { back.tap() }
        }

        XCTAssertTrue(section.waitForExistence(timeout: 10), "No sidebar section \(tab)", file: file, line: line)
        section.tap()
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
