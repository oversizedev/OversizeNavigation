//
// Copyright © 2025 Alexander Romanov
// NavigationDestinationModifier.swift, created on 09.06.2025
//

import NavigatorUI
import OversizeCore
import SwiftUI

private struct NavigationMoveModifier<T: Hashable & Equatable>: ViewModifier {
    @Binding var item: T?
    @Environment(\.navigator) var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: item) { _, item in
                if let item {
                    Log.debug("🧭 [NAVIGATION] Move to: \(item)")
                    navigator.send(item)
                    self.item = nil
                }
            }
    }
}

private struct NavigationMoveValuesModifier: ViewModifier {
    @Binding var values: [AnyHashable]?
    @Environment(\.navigator) var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: values) { _, values in
                if let values, values.isEmpty == false {
                    Log.debug("🧭 [NAVIGATION] Move to: \(values)")
                    navigator.send(values: values.compactMap { $0.base as? any Hashable })
                    self.values = nil
                }
            }
    }
}

public extension View {
    func navigationMove<T: Hashable & Equatable>(_ item: Binding<T?>) -> some View {
        modifier(NavigationMoveModifier<T>(item: item))
    }

    /// Broadcasts an ordered list of values, each handled by whichever receiver registered for
    /// its type — the shape of a deep link that has to switch tab before it can push.
    func navigationMove(values: Binding<[AnyHashable]?>) -> some View {
        modifier(NavigationMoveValuesModifier(values: values))
    }
}
