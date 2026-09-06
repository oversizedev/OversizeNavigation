//
// Copyright © 2026 Alexander Romanov
// NavigationDismissModifier.swift, created on 05.09.2026
//

import SwiftUI

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
