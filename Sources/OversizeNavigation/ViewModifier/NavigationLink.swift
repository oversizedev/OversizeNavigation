//
// Copyright © 2026 Alexander Romanov
// NavigationLink.swift, created on 11.05.2026
//

import NavigatorUI
import SwiftUI

public extension NavigationLink where Destination == Never {
    /// Mirrors the NavigatorUI initializer so that call sites depend on OversizeNavigation only,
    /// which keeps the door open for swapping the navigation framework underneath.
    ///
    /// NavigatorUI ships the same initializer, so a file importing both modules would otherwise
    /// see an ambiguous call. Disfavoring this overload hands those files to NavigatorUI while
    /// files importing OversizeNavigation alone keep working.
    @_disfavoredOverload
    @MainActor
    init<D: NavigationDestination>(to destination: D, @ViewBuilder label: () -> Label) {
        self.init(value: AnyNavigationDestination(destination), label: label)
    }
}
