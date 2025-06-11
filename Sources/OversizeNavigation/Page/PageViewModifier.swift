//
// Copyright © 2025 Alexander Romanov
// PageViewModifier.swift, created on 07.06.2025
//

import SwiftUI

public extension PageView {
    func toolbarImage(_ image: Image?) -> PageView {
        var control = self
        control.logo = image
        return control
    }

    func emptyContent(_ isEmpty: Bool = true) -> PageView {
        var control = self
        control.isEmptyContent = isEmpty
        return control
    }
}
