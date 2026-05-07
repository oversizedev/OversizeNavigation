//
// Copyright © 2025 Alexander Romanov
// NavigationListCoverLayoutViewModifier.swift, created on 06.05.2026
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension NavigationListCoverLayoutView {
    func backConfirmationDialog(_ content: BackConfirmationContent? = .dismiss) -> Self {
        var control = self
        control.backConfirmation = content
        return control
    }

    func backConfirmationDialog(
        title: String,
        message: String,
        confirmationButtonTitle: String,
        cancelButtonTitle: String? = nil
    ) -> Self {
        var control = self
        control.backConfirmation = .init(
            title: title,
            message: message,
            confirmationButtonTitle: confirmationButtonTitle,
            cancelButtonTitle: cancelButtonTitle
        )
        return control
    }

    func listLayoutStyle(_ listStyle: OversizeUI.ListLayoutStyle) -> Self {
        var list = self
        list.listStyle = listStyle
        return list
    }
}
