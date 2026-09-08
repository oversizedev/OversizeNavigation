//
// Copyright © 2026 Alexander Romanov
// ExampleUITestCase.swift, created on 05.09.2026
//

import XCTest

@MainActor
class ExampleUITestCase: XCTestCase {
    /// The layouts install their own control only where the package documents one: the system
    /// button stays in place on an ordinary push.
    enum BackControl {
        /// The button SwiftUI provides for a pushed screen.
        case system
        /// The control a layout installs when a back confirmation is set — a pop.
        case confirmation
        /// The control a layout installs at the root of a presentation — a close.
        case close
    }

    var app: XCUIApplication!

    /// How long to wait for an element before calling it missing.
    ///
    /// A Mac runner is markedly slower to bring the window up than a simulator: the CI log shows
    /// a passing `testEveryTabIsReachable` taking nine seconds, with other tests failing at the
    /// ten second mark on the very same sidebar. A short budget turns that into "no control
    /// opens Flows", which reads like a broken query rather than a slow launch.
    var elementTimeout: TimeInterval {
        #if os(macOS)
            30
        #else
            10
        #endif
    }

    /// Synchronous on purpose. With `continueAfterFailure = false` XCTest stops a failed test by
    /// raising an Objective-C exception, and an exception raised while the case still has async
    /// machinery on the stack cannot unwind through it — on macOS the runner process dies, xcodebuild
    /// restarts it per remaining test, and one red assertion reads as thirty. The window the app
    /// then fails to open on those relaunches is `ExampleApp`'s side of the same incident.
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ExampleUITesting"]
        app.launch()
    }

    /// Whether this run mounts the split root. The Mac starts there, and on iOS it is only
    /// reached by toggling — which is what `RootType.defaultForPlatform` states.
    var isSplitRootByDefault: Bool {
        #if os(macOS)
            true
        #else
            false
        #endif
    }

    /// The same four sections reach the screen through three different controls: a tab bar in a
    /// compact width, a tab strip at the top on iPad, and a sidebar under the split root — the
    /// only one a Mac window has.
    func openTab(_ title: String, file: StaticString = #filePath, line: UInt = #line) {
        let control = tabControl(title)
        XCTAssertTrue(
            control.waitForExistence(timeout: elementTimeout),
            "No control opens \(title) in this layout. \(launchDiagnostics())",
            file: file,
            line: line
        )
        control.tap()
    }

    /// Whether the app put anything on screen at all is the first question a "no control" failure
    /// has to answer: a macOS launch that restored a zero-window scene publishes a menu bar over
    /// an empty tree, and that reads identically to a wrong query unless the tree size is in the
    /// message.
    func launchDiagnostics() -> String {
        "state=\(app.state.rawValue) windows=\(windowTitles) "
            + "buttons=\(app.buttons.count) texts=\(app.staticTexts.count)"
    }

    /// A sidebar row by its identifier, whatever element type the platform publishes it as.
    /// A `NavigationLink` row was a button; a plain selectable `Label` row is a cell on macOS
    /// and a static text elsewhere, so the query cannot commit to a type.
    ///
    /// The identifier a row carries is inherited by everything the `Label` builds, and on iPadOS
    /// the first of those matches is the leading icon — an image whose hit point resolves to
    /// `{-1, -1}`, so every tap on it fails while the row itself is perfectly tappable. The
    /// element that can be tapped is therefore preferred over the plain first match.
    func sidebarRow(_ identifier: String) -> XCUIElement {
        let matches = app.descendants(matching: .any).matching(identifier: identifier)
        for index in 0 ..< matches.count {
            let candidate = matches.element(boundBy: index)
            if candidate.exists, candidate.isHittable {
                return candidate
            }
        }

        return matches.firstMatch
    }

    /// The control that selects a section, whichever root is mounted. The last branch scans
    /// every button on screen, so it is only reached when neither a tab bar nor a sidebar is
    /// mounted — the iPad tab strip.
    ///
    /// The candidates are polled rather than picked from the first snapshot: a root that has not
    /// finished mounting publishes none of them yet, and committing to the fallback there would
    /// return a query that can never resolve — the sidebar row is a cell, not a button.
    func tabControl(_ title: String) -> XCUIElement {
        let deadline = Date().addingTimeInterval(elementTimeout)
        repeat {
            if let control = mountedTabControl(title) {
                return control
            }
            Thread.sleep(forTimeInterval: 0.25)
        } while Date() < deadline

        return mountedTabControl(title) ?? sidebarRow("sidebar.\(title.lowercased())")
    }

    private func mountedTabControl(_ title: String) -> XCUIElement? {
        let sidebar = sidebarRow("sidebar.\(title.lowercased())")
        if sidebar.exists {
            return sidebar
        }

        #if !os(macOS)
            let tab = app.tabBars.buttons[title]
            if tab.exists {
                return tab
            }
        #endif

        let labelled = app.buttons.matching(NSPredicate(format: "label == %@", title)).firstMatch
        return labelled.exists ? labelled : nil
    }

    /// Rows below the fold are not created until the list scrolls to them. A row that ends up
    /// underneath the tab bar still reports `isHittable`, and tapping it selects a tab instead of
    /// running the row, so it has to be scrolled clear of the bar as well.
    ///
    /// Scrolling drives the list rather than `app`: a swipe on the application element is
    /// resolved against the whole accessibility tree and can land on the tab bar or a HUD.
    @discardableResult
    func row(_ identifier: String, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        let element = app.buttons[identifier]
        _ = element.waitForExistence(timeout: elementTimeout / 2)

        let scroller = scrollableContainer()
        var attempts = 0
        while element.exists == false || element.isHittable == false || isCoveredByTabBar(element), attempts < 6 {
            scroller.swipeUp()
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

    /// The layouts render as a collection view, a table or a plain scroll view depending on the
    /// list style, and swiping the application element instead resolves the gesture against the
    /// whole tree — where the tab bar or a HUD can take it.
    ///
    /// Under a split root the sidebar is a scrollable container too, and it precedes the detail
    /// column, so taking `firstMatch` would scroll the sidebar while the row stays below the
    /// fold. Containers that sit within the sidebar's width are skipped for that reason.
    private func scrollableContainer() -> XCUIElement {
        let sidebarEdge = sidebarTrailingEdge()

        for container in [app.collectionViews, app.tables, app.outlines, app.scrollViews] {
            for index in 0 ..< container.count {
                let candidate = container.element(boundBy: index)
                guard candidate.exists else { continue }
                if candidate.frame.minX >= sidebarEdge {
                    return candidate
                }
            }
        }
        return app
    }

    /// Where the sidebar ends, or zero when no sidebar is mounted.
    private func sidebarTrailingEdge() -> CGFloat {
        let anySidebarRow = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "sidebar.")
        ).firstMatch

        guard anySidebarRow.exists else { return 0 }
        return anySidebarRow.frame.maxX
    }

    /// Only a bar sitting at the bottom of the window can swallow a tap meant for a row; the
    /// iPad tab strip lives at the top and covers nothing, and a Mac window has no tab bar.
    private func isCoveredByTabBar(_ element: XCUIElement) -> Bool {
        #if os(macOS)
            return false
        #else
            let tabBar = app.tabBars.firstMatch
            guard element.exists, tabBar.exists else { return false }
            guard tabBar.frame.minY > app.frame.midY else { return false }

            return element.frame.maxY > tabBar.frame.minY
        #endif
    }

    func tapRow(_ identifier: String, file: StaticString = #filePath, line: UInt = #line) {
        row(identifier, file: file, line: line).tap()
    }

    /// A stack that misroutes a push renders it in a tab nobody is looking at, so the
    /// destination alone does not prove the navigation stayed where it started.
    func assertSelectedTab(_ title: String, file: StaticString = #filePath, line: UInt = #line) {
        let control = tabControl(title)
        XCTAssertTrue(
            control.waitForExistence(timeout: elementTimeout),
            "No control opens \(title) in this layout",
            file: file,
            line: line
        )

        XCTAssertTrue(
            isSectionSelected(title, control: control),
            "Expected \(title) to stay selected. \(selectionDiagnostics(title))",
            file: file,
            line: line
        )
    }

    /// A tab bar button reports its own selection; a sidebar row is selected through the list that
    /// contains it, so the flag can sit on the enclosing cell rather than on the row's button.
    private func isSectionSelected(_ title: String, control: XCUIElement) -> Bool {
        if control.isSelected {
            return true
        }

        #if os(macOS)
            let identifier = "sidebar.\(title.lowercased())"
            for container in [app.cells, app.outlineRows, app.tableRows] {
                let row = container.containing(.any, identifier: identifier).firstMatch
                if row.exists, row.isSelected {
                    return true
                }
            }
        #endif

        return false
    }

    private func selectionDiagnostics(_ title: String) -> String {
        let identifier = "sidebar.\(title.lowercased())"
        let row = sidebarRow(identifier)
        var report = "control=\(row.exists ? "exists" : "missing") selected=\(row.exists ? "\(row.isSelected)" : "-") "
        report += "cells=\(app.cells.count) outlineRows=\(app.outlineRows.count) "
        report += "windows=\(windowTitles)"
        return report
    }

    /// The split root replaces the tab bar with a sidebar, which collapses into a stack in a
    /// compact width — there the sidebar is only reachable after popping the detail column.
    func openSidebarSection(_ tab: String, file: StaticString = #filePath, line: UInt = #line) {
        let identifier = "sidebar.\(tab)"

        if sidebarRow(identifier).waitForExistence(timeout: elementTimeout / 2) == false {
            let back = backNavigationBars.buttons.firstMatch
            if back.exists {
                back.tap()
            }
        }

        XCTAssertTrue(
            sidebarRow(identifier).waitForExistence(timeout: elementTimeout),
            "No sidebar section \(tab)",
            file: file,
            line: line
        )
        // Resolved again only now: `sidebarRow` picks the tappable element out of the ones the
        // row publishes, and it can only do that once the row is actually on screen.
        sidebarRow(identifier).tap()
    }

    /// A Mac renders `navigationTitle` as the window's title rather than into a navigation bar.
    func assertScreen(_ title: String, file: StaticString = #filePath, line: UInt = #line) {
        if waitForScreen(title) {
            return
        }

        XCTFail(
            "Expected to be on \(title). \(titleDiagnostics(title))",
            file: file,
            line: line
        )
    }

    /// Where a screen title actually lives differs per platform, and a failure that only says
    /// "not found" gives nothing to fix. Report the candidates so the log names them.
    private func titleDiagnostics(_ title: String) -> String {
        var report = ""

        report += "windows=\(windowTitles) "

        let toolbarTexts = (0 ..< min(app.toolbars.staticTexts.count, 8)).map { index in
            app.toolbars.staticTexts.element(boundBy: index).label
        }
        report += "toolbarTexts=\(toolbarTexts) "

        let matching = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", title))
        let kinds = (0 ..< min(matching.count, 6)).map { index -> String in
            let element = matching.element(boundBy: index)
            return "\(element.elementType.rawValue)@\(Int(element.frame.minX))"
        }
        report += "labelled=\(kinds) "

        // Label and value both: macOS publishes some SwiftUI texts with the string in the
        // element's value and an empty label, and a label-only report hides exactly the
        // texts a failure needs to see.
        let texts = (0 ..< min(app.staticTexts.count, 14)).map { index -> String in
            let element = app.staticTexts.element(boundBy: index)
            return "\(element.label)|\(element.value.map { "\($0)" } ?? "")"
        }
        report += "staticTexts=\(texts)"

        return report
    }

    /// Polls rather than resolving a query once. Which element carries the title on macOS depends
    /// on how far the transition has got — before the new title is published there is no matching
    /// text at all — so an element captured from the first snapshot can be one that will never
    /// exist, and waiting on it fails even after the real title appears.
    @discardableResult
    func waitForScreen(_ title: String, timeout: TimeInterval? = nil) -> Bool {
        let timeout = timeout ?? elementTimeout
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if isShowingScreen(title) {
                return true
            }
            Thread.sleep(forTimeInterval: 0.25)
        } while Date() < deadline

        return isShowingScreen(title)
    }

    private func isShowingScreen(_ title: String) -> Bool {
        #if os(macOS)
            // `navigationTitle` becomes the window's title, which is where a screen hosted by the
            // window announces itself. The sidebar publishes rows labelled like the screens they
            // open and the detail column keeps showing the catalog row that started a push, so a
            // plain text search would report the previous screen as the current one — the window
            // title is the unambiguous source.
            if windowTitles.contains(title) {
                return true
            }
            // A sheet has no title bar, so its `navigationTitle` and that of anything pushed on
            // top of it are published nowhere at all; those screens name themselves instead.
            return app.descendants(matching: .any)["screen.\(title)"].exists
        #else
            return app.navigationBars[title].exists
        #endif
    }

    /// The titles of the app's windows. On macOS the frontmost one names the current screen.
    private var windowTitles: [String] {
        (0 ..< min(app.windows.count, 4)).map { index in
            app.windows.element(boundBy: index).title
        }
    }

    /// The container the back control lives in. iOS publishes a navigation bar; a Mac window
    /// publishes a toolbar.
    private var backNavigationBars: XCUIElementQuery {
        #if os(macOS)
            app.toolbars
        #else
            app.navigationBars
        #endif
    }

    func tapBack(_ control: BackControl, file: StaticString = #filePath, line: UInt = #line) {
        let button = backButton(control)
        XCTAssertTrue(
            button.waitForExistence(timeout: elementTimeout),
            "No \(control) back control on screen",
            file: file,
            line: line
        )
        button.tap()
    }

    /// The layouts identify the control they install by its role, so the same query works on
    /// both platforms. The system button has no identifier of ours and is addressed per
    /// platform instead.
    func backButton(_ control: BackControl) -> XCUIElement {
        switch control {
        case .system:
            #if os(macOS)
                // A split view's toolbar also carries the sidebar toggle, and it comes first —
                // `firstMatch` would collapse the sidebar instead of popping the screen.
                let labelled = app.buttons["Back"]
                if labelled.exists {
                    return labelled
                }
                let chevron = app.buttons["chevron.backward"]
                if chevron.exists {
                    return chevron
                }
                return backNavigationBars.buttons.matching(
                    NSPredicate(format: "label CONTAINS[c] %@", "back")
                ).firstMatch
            #else
                return app.buttons["BackButton"]
            #endif
        case .confirmation:
            return layoutBackControl(identifier: "navigationBack.pop", label: "Back")
        case .close:
            return layoutBackControl(identifier: "navigationBack.close", label: "Close")
        }
    }

    /// The control a layout installs, addressed by the role it was installed for.
    ///
    /// macOS does not publish the accessibility identifier of the pane header's button — the
    /// button is in the tree and answers to its label, the identifier reads back empty — so the
    /// control is addressed there by the word it shows. `BackButtonPolicy.backButtonRole` picks
    /// both the identifier and that word, so a pop and a close stay distinguishable either way.
    private func layoutBackControl(identifier: String, label: String) -> XCUIElement {
        let identified = app.buttons[identifier]
        #if os(macOS)
            if identified.exists {
                return identified
            }
            // A window's own close button carries the same word; the standard window controls
            // identify themselves with an `_XCUI:` prefix and are excluded by it.
            return app.buttons.matching(
                NSPredicate(format: "label == %@ AND NOT (identifier BEGINSWITH %@)", label, "_XCUI:")
            ).firstMatch
        #else
            return identified
        #endif
    }

    /// A control a layout installs itself, as opposed to one the system provides.
    func hasCustomBackControl() -> Bool {
        layoutBackControl(identifier: "navigationBack.pop", label: "Back").exists
            || layoutBackControl(identifier: "navigationBack.close", label: "Close").exists
    }

    /// The dialog's own sheet is queried first on macOS: the action it names can also exist in
    /// the screen underneath, and the bare `app.buttons[title]` then matches both and refuses
    /// the tap.
    func tapDialogButton(_ title: String, file: StaticString = #filePath, line: UInt = #line) {
        #if os(macOS)
            let button = app.sheets.buttons[title].exists
                ? app.sheets.buttons[title]
                : app.buttons[title].firstMatch
        #else
            let button = app.buttons[title]
        #endif
        XCTAssertTrue(
            button.waitForExistence(timeout: elementTimeout),
            "No \(title) button",
            file: file,
            line: line
        )
        button.tap()
    }

    /// The button of a presented alert. iOS publishes alerts under `alerts`; a Mac renders them
    /// as a dialog or sheet, and which container carries the buttons is only knowable once the
    /// alert is actually on screen — so the containers are polled rather than resolved once.
    func alertButton(_ title: String, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        #if os(macOS)
            let candidates = [
                app.alerts.buttons[title],
                app.dialogs.buttons[title],
                app.sheets.buttons[title],
            ]
            let deadline = Date().addingTimeInterval(elementTimeout / 2)
            repeat {
                if let present = candidates.first(where: { $0.exists }) {
                    return present
                }
                Thread.sleep(forTimeInterval: 0.25)
            } while Date() < deadline

            XCTFail("No alert with a \(title) button on screen", file: file, line: line)
            return app.alerts.buttons[title]
        #else
            let button = app.alerts.buttons[title]
            XCTAssertTrue(
                button.waitForExistence(timeout: elementTimeout / 2),
                "No alert with a \(title) button on screen",
                file: file,
                line: line
            )
            return button
        #endif
    }

    /// Taps a button of the presented alert. macOS publishes alert buttons with no frame
    /// (`{{inf, inf}, {0, 0}}`), so a plain pointer tap has no hit point there. The cancel role
    /// has a reliable keyboard equivalent — Escape — but a destructive action deliberately has
    /// none, so it is clicked through whichever related element still carries real geometry.
    func tapAlertButton(
        _ title: String,
        cancels: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let button = alertButton(title, file: file, line: line)
        #if os(macOS)
            if cancels {
                app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
                return
            }
            if button.isHittable {
                button.tap()
                return
            }
            let innerText = app.staticTexts.matching(
                NSPredicate(format: "label == %@ OR value == %@", title, title)
            ).firstMatch
            if innerText.exists, innerText.isHittable {
                innerText.tap()
                return
            }
            app.typeKey(XCUIKeyboardKey.return, modifierFlags: [])
        #else
            button.tap()
        #endif
    }

    /// What the presented alert actually looks like to the tree, for failures around it.
    func alertDiagnostics() -> String {
        var report = "windows=\(windowTitles) dialogs=\(app.dialogs.count) sheets=\(app.sheets.count) alerts=\(app.alerts.count) "
        let buttons = (0 ..< min(app.buttons.count, 20)).compactMap { index -> String? in
            let element = app.buttons.element(boundBy: index)
            guard element.identifier.hasPrefix("action-button") || element.frame.origin.x.isInfinite else { return nil }
            return "\(element.identifier)|\(element.title)@\(element.frame.origin.x)"
        }
        report += "alertButtons=\(buttons)"
        return report
    }

    /// A static text matched by label or value. macOS publishes some SwiftUI texts with the
    /// string in the element's value and an empty label, where iOS always uses the label.
    func staticText(_ string: String) -> XCUIElement {
        app.staticTexts.matching(
            NSPredicate(format: "label == %@ OR value == %@", string, string)
        ).firstMatch
    }

    /// iOS renders the cancel role of a confirmation dialog as the region outside it; a Mac
    /// renders the dialog as a sheet whose cancel role is an ordinary button.
    func dismissDialog(file: StaticString = #filePath, line: UInt = #line) {
        #if os(macOS)
            let cancel = app.sheets.buttons["Cancel"].exists
                ? app.sheets.buttons["Cancel"]
                : app.buttons["Cancel"]
            XCTAssertTrue(
                cancel.waitForExistence(timeout: elementTimeout),
                "No dialog on screen",
                file: file,
                line: line
            )
            cancel.tap()
        #else
            let region = app.otherElements["PopoverDismissRegion"]
            XCTAssertTrue(
                region.waitForExistence(timeout: elementTimeout),
                "No dialog on screen",
                file: file,
                line: line
            )
            region.tap()
        #endif
    }
}
