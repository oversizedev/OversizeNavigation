//
// Copyright © 2026 Alexander Romanov
// NavigationLockedModifier.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

public extension View {
    /// Blocks a global dismiss while this screen is on the stack, for a transaction that must
    /// not be torn down by a deep link arriving from elsewhere.
    ///
    /// > Important: The body calls the NavigatorUI overload, not itself — `@_disfavoredOverload`
    /// is what breaks the tie between two identical signatures. If NavigatorUI ever renames or
    /// re-signs it, this binds to itself and overflows the stack at runtime with nothing to warn
    /// you. The package tests import NavigatorUI, so they exercise the original; only a call site
    /// importing OversizeNavigation alone covers this shim, which is what `Example/Example/Screens`
    /// is for.
    @_disfavoredOverload
    @MainActor
    func navigationLocked() -> some View {
        navigationLocked()
    }
}
