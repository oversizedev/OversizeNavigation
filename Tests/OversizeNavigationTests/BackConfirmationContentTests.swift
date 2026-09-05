//
// Copyright © 2026 Alexander Romanov
// BackConfirmationContentTests.swift, created on 05.09.2026
//

import Testing
@testable import OversizeNavigation

struct BackConfirmationContentTests {
    @Test("The dismiss preset asks before leaving")
    func dismissPreset() {
        let content = BackConfirmationContent.dismiss

        #expect(content.title == "Are you sure you want to dismiss?")
        #expect(content.message.isEmpty)
        #expect(content.confirmationButtonTitle == "Dismiss")
        #expect(content.cancelButtonTitle == "Cancel")
    }

    @Test("The discard preset explains the unsaved changes")
    func discardPreset() {
        let content = BackConfirmationContent.discard

        #expect(content.title == "Do you want to discard?")
        #expect(content.message == "You have unsaved changes")
        #expect(content.confirmationButtonTitle == "Discard Changes")
        #expect(content.cancelButtonTitle == "Cancel")
    }

    @Test("A custom content keeps its cancel title optional")
    func customContentWithoutCancelTitle() {
        let content = BackConfirmationContent(
            title: "Stop editing?",
            message: "The draft will be lost",
            confirmationButtonTitle: "Stop",
            cancelButtonTitle: nil
        )

        #expect(content.cancelButtonTitle == nil)
    }
}
