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
    /// is what breaks the tie between two identical signatures. Should NavigatorUI ever rename or
    /// re-sign it, this call binds to itself, and a `some View` whose only return is a recursive
    /// call has no underlying type to infer, so the package stops building. The failure is loud
    /// and local; it is not a runtime trap.
    @_disfavoredOverload
    @MainActor
    func navigationLocked() -> some View {
        navigationLocked()
    }
}
