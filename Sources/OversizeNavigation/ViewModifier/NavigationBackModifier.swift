//
// Copyright © 2025 Alexander Romanov
// NavigationBackModifier.swift, created on 09.06.2025
//

import NavigatorUI
import OversizeCore
import SwiftUI

private struct NavigationBackModifier: ViewModifier {
    @Binding var trigger: Bool

    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, trigger in
                if trigger {
                    Log.debug("🧭 [NAVIGATION] Back")
                    navigator.back()
                    self.trigger = false
                }
            }
    }
}

public extension View {
    /// Leaves the screen whenever the trigger becomes `true`, then resets it — a pop on a
    /// pushed screen, a dismiss at the root of a presentation. Use ``navigationDismiss(_:)``
    /// when the screen has to leave the presentation it lives in regardless of its depth.
    func navigationBack(_ trigger: Binding<Bool>) -> some View {
        modifier(NavigationBackModifier(trigger: trigger))
    }
}
