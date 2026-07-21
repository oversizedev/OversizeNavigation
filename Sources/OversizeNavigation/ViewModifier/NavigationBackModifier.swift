//
// Copyright © 2025 Alexander Romanov
// NavigationSendValueModifier.swift, created on 09.06.2025
//

import NavigatorUI
import SwiftUI

private struct NavigationBackModifier: ViewModifier {
    @Binding var trigger: Bool

    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, trigger in
                if trigger {
                    navigator.back()
                }
            }
    }
}

public extension View {
    func navigationBack(_ trigger: Binding<Bool>) -> some View {
        modifier(NavigationBackModifier(trigger: trigger))
    }
}
