//
// Copyright © 2026 Alexander Romanov
// NavigationLink.swift, created on 11.05.2026
//

import NavigatorUI
import SwiftUI

public extension NavigationLink where Destination == Never {
    @MainActor
    init<D: NavigationDestination>(to destination: D, @ViewBuilder label: () -> Label) {
        self.init(value: AnyNavigationDestination(destination), label: label)
    }
}
