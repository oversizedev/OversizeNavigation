//
// Copyright © 2025 Alexander Romanov
// NavigationCoverPageViewModifier.swift, created on 07.06.2025
//

import OversizeUI
import SwiftUI

public extension NavigationCoverPageView {
    func toolbarImage(_ image: Image) -> Self {
        var control = self
        control.logo = image
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

    func coverStyle(_ coverStyle: CoverNavigationType) -> Self {
        var control = self
        control.coverStyle = coverStyle
        return control
    }

    func contentCornerRadius(_ radius: CGFloat) -> Self {
        var control = self
        control.contentCornerRadius = radius
        return control
    }

    func contentCornerRadius(_ radius: Radius) -> Self {
        var control = self
        control.contentCornerRadius = radius.rawValue
        return control
    }
}
