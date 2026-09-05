//
// Copyright © 2026 Alexander Romanov
// NavigationInfo.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

/// Read-only state of the stack a screen lives on, so a screen can describe where it is
/// without reaching for the navigator itself.
public struct NavigationInfo: Sendable {
    private let navigator: Navigator

    init(navigator: Navigator) {
        self.navigator = navigator
    }

    /// How many screens are pushed on top of the root of this stack.
    @MainActor public var depth: Int {
        navigator.count
    }

    /// True while nothing is pushed on top of the root of this stack.
    @MainActor public var isRoot: Bool {
        navigator.count == 0
    }

    /// True when this stack is presented as a sheet or a cover.
    @MainActor public var isPresented: Bool {
        navigator.isPresented
    }

    /// True when the checkpoint is known to the navigation tree and can be returned to.
    @MainActor public func canReturn(to checkpoint: NavigationCheckpoint<some Any>) -> Bool {
        navigator.canReturnToCheckpoint(checkpoint)
    }
}

public extension EnvironmentValues {
    var navigationInfo: NavigationInfo {
        .init(navigator: navigator)
    }
}
