//
// Copyright © 2026 Alexander Romanov
// LayoutsUITests.swift, created on 05.09.2026
//

import XCTest

final class LayoutsUITests: ExampleUITestCase {
    private static let pushedLayouts: [(row: String, title: String)] = [
        ("layouts.navigationLayout", "NavigationLayout"),
        ("layouts.listLayout", "NavigationListLayout"),
        ("layouts.selectableListLayout", "Selection"),
        ("layouts.coverLayout", "NavigationCoverLayout"),
        ("layouts.listCoverLayout", "NavigationListCoverLayout"),
    ]

    @MainActor
    func testEveryLayoutOpensAndCloses() throws {
        openTab("Layouts")

        for layout in Self.pushedLayouts {
            tapRow(layout.row)
            assertScreen(layout.title)

            tapBack(.system)
            assertScreen("Layouts")
        }
    }

    @MainActor
    func testBackConfirmationCanBeCancelled() throws {
        openTab("Layouts")
        tapRow("layouts.backConfirmationPushed")
        assertScreen("Pushed with confirmation")

        tapBack(.confirmation)
        dismissDialog()

        assertScreen("Pushed with confirmation")
    }

    @MainActor
    func testBackConfirmationPopsWhenConfirmed() throws {
        openTab("Layouts")
        tapRow("layouts.backConfirmationPushed")
        assertScreen("Pushed with confirmation")

        tapBack(.confirmation)
        tapDialogButton("Discard Changes")

        assertScreen("Layouts")
    }

    @MainActor
    func testSheetConfirmationDismissesTheSheet() throws {
        openTab("Layouts")
        tapRow("layouts.backConfirmationSheet")
        assertScreen("Sheet with confirmation")

        tapBack(.close)
        tapDialogButton("Discard Changes")

        assertScreen("Layouts")
    }
}
