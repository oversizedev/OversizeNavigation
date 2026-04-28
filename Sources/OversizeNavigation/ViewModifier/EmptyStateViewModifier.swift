//
// Copyright © 2026 Alexander Romanov
// EmptyStateViewModifier.swift, created on 10.04.2026
//

import OversizeCore
import OversizeUI
import SwiftUI

public struct EmptyStateModifier<EmptyContent: View, Result: Sendable & Emptyable>: ViewModifier {
    let state: LoadingState<Result>
    let emptyContent: () -> EmptyContent

    public func body(content: Content) -> some View {
        content
            .overlay {
                switch state {
                case let .result(result) where result.isEmpty:
                    ZStack {
                        Color.backgroundPrimary.ignoresSafeArea()
                        emptyContent()
                    }
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

public struct SearchableEmptyStateModifier<EmptyResultContent: View, EmptySearchContent: View, Result: Sendable & Emptyable & SearchableState>: ViewModifier {
    let state: LoadingState<Result>
    let emptyResultContent: () -> EmptyResultContent
    let emptySearchContent: () -> EmptySearchContent

    public func body(content: Content) -> some View {
        content
            .overlay {
                switch state {
                case let .result(result) where result.isEmpty:
                    ZStack {
                        Color.backgroundPrimary.ignoresSafeArea()
                        if result.isSearch {
                            emptySearchContent()
                        } else {
                            emptyResultContent()
                        }
                    }
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
    func emptyState<EmptyResultContent: View, EmptySearchContent: View, Result: Sendable & Emptyable & SearchableState>(
        _ state: LoadingState<Result>,
        emptyResultContent: @escaping () -> EmptyResultContent,
        emptySearchContent: @escaping () -> EmptySearchContent
    ) -> some View {
        modifier(
            SearchableEmptyStateModifier(
                state: state,
                emptyResultContent: emptyResultContent,
                emptySearchContent: emptySearchContent
            )
        )
    }

    func emptyState<EmptyContent: View, Result: Sendable & Emptyable>(
        _ state: LoadingState<Result>,
        emptyContent: @escaping () -> EmptyContent
    ) -> some View {
        modifier(
            EmptyStateModifier(
                state: state,
                emptyContent: emptyContent
            )
        )
    }

    func emptyState<Result: Sendable & Emptyable>(
        _ state: LoadingState<Result>,
        image: Image? = nil,
        title: String = "Nothing Here",
        subtitle: String? = "There is no content to show"
    ) -> some View {
        modifier(
            EmptyStateModifier<EmptyStateView<EmptyView>, Result>(
                state: state,
                emptyContent: {
                    EmptyStateView(
                        image: image,
                        title: title,
                        subtitle: subtitle
                    )
                }
            )
        )
    }
}
