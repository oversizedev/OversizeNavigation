//
// Copyright © 2026 Alexander Romanov
// EmptyStateViewModifier.swift, created on 10.04.2026
//

import OversizeCore
import OversizeUI
import SwiftUI

public struct ErrorStateViewModifier<Result: Sendable>: ViewModifier {
    let state: LoadingState<Result>

    public func body(content: Content) -> some View {
        content
            .overlay {
                switch state {
                case let .error(error):
                    ZStack {
                        Color.backgroundPrimary.ignoresSafeArea()
                        ErrorView(error: error)
                    }
                default:
                    EmptyView()
                }
            }
    }
}

@MainActor
public extension View {
    func errorState<Result: Sendable>(_ state: LoadingState<Result>) -> some View {
        modifier(
            ErrorStateViewModifier(state: state)
        )
    }
}
