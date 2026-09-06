//
// Copyright © 2026 Alexander Romanov
// NavigationDismissModifier.swift, created on 05.09.2026
//

import SwiftUI

// Leaving a screen used to be three modifiers whose names did not say how far they went, so a
// screen at the root of a sheet could pick either of the first two and see no difference.
// ``NavigationExit`` states the depth instead; these forward to it until call sites migrate.
public extension View {
    @available(*, deprecated, message: "Use .navigationBack($trigger, to: .presentation)")
    func navigationDismiss(_ trigger: Binding<Bool>) -> some View {
        navigationBack(trigger, to: .presentation)
    }

    @available(*, deprecated, message: "Use .navigationBack($trigger, to: .allPresentations) { result in }")
    func navigationDismissAny(
        _ trigger: Binding<Bool>,
        completion: ((Result<Bool, any Error>) -> Void)? = nil
    ) -> some View {
        navigationBack(trigger, to: .allPresentations, completion: completion)
    }
}
