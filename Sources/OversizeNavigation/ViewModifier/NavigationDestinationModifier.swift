//
// Copyright © 2025 Alexander Romanov
// NavigationDestinationModifier.swift, created on 09.06.2025
//

import NavigatorUI
import SwiftUI

private struct NavigationDestinationValueModifier<T: Hashable & Equatable>: ViewModifier {
    @Binding var item: T?
    @Environment(\.navigator) var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: item) { _, item in
                if let item {
                    navigator.send(item)
                    self.item = nil
                }
            }
    }
}

public extension View {
    func navigationMove<T: Hashable & Equatable>(_ item: Binding<T?>) -> some View {
        modifier(NavigationDestinationValueModifier<T>(item: item))
    }
}
