//
// Copyright © 2026 Alexander Romanov
// NavigationListLayoutModifier.swift, created on 30.08.2026
//

import OversizeUI
import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension NavigationListLayout {
    func backButtonHidden(_ hidesBackButton: Bool = true) -> Self {
        var control = self
        control.isBackButtonHidden = hidesBackButton
        return control
    }

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

    func listLayoutStyle(_ listStyle: ListLayoutStyle) -> Self {
        var list = self
        list.listStyle = listStyle
        return list
    }
}
