//
// Copyright © 2026 Alexander Romanov
// NavigationLockedModifier.swift, created on 05.09.2026
//

import NavigatorUI
import SwiftUI

public extension View {
    /// Blocks a global dismiss while this screen is on the stack, for a transaction that must
    /// not be torn down by a deep link arriving from elsewhere.
    @_disfavoredOverload
    @MainActor
    func navigationLocked() -> some View {
        navigationLocked()
    }
}
