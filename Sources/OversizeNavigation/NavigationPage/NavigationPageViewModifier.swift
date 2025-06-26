//
// Copyright © 2025 Alexander Romanov
// NavigationPageViewModifier.swift, created on 07.06.2025
//

import SwiftUI

public extension NavigationPageView {
    func toolbarImage(_ image: Image) -> Self {
        var control = self
        control.logo = image
        return control
    }

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
}
