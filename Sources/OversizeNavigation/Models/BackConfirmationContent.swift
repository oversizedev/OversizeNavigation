//
// Copyright © 2025 Alexander Romanov
// BackConfirmationContent.swift, created on 07.06.2025
//

public struct BackConfirmationContent: Sendable {
    public let title: String
    public let message: String
    public let confirmationButtonTitle: String
    public let cancelButtonTitle: String?

    public static let dismiss = BackConfirmationContent(
        title: "Are you sure you want to dismiss?",
        message: "",
        confirmationButtonTitle: "Dismiss",
        cancelButtonTitle: "Cancel"
    )

    public static let discard = BackConfirmationContent(
        title: "Do you want to discard?",
        message: "You have unsaved changes",
        confirmationButtonTitle: "Discard Changes",
        cancelButtonTitle: "Cancel"
    )
}
