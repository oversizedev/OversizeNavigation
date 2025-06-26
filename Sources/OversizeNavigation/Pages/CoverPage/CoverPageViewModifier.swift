//
// Copyright © 2025 Alexander Romanov
// PageViewModifier.swift, created on 07.06.2025
//

import OversizeUI
import SwiftUI

public extension CoverPageView {
    func toolbarImage(_ image: Image?) -> Self {
        var control = self
        control.logo = image
        return control
    }

    func coverStyle(_ coverStyle: CoverNavigationType) -> Self {
        var control = self
        control.coverStyle = coverStyle
        return control
    }

    func toolbarImage(_ image: Image) -> Self {
        var control = self
        control.logo = image
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
