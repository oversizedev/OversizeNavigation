//
// Copyright © 2026 Alexander Romanov
// ContentUnavailableModifier.swift, created on 10.04.2026
//

import OversizeCore
import OversizeUI
import SwiftUI

public struct ContentUnavailableModifier<OverlayContent: View, Result: Sendable & Emptyable>: ViewModifier {
    let state: LoadingState<Result>
    let content: () -> OverlayContent

    public func body(content: Content) -> some View {
        content
            .overlay {
                switch state {
                case let .result(result) where result.isEmpty:
                    ZStack {
                        Color.backgroundPrimary.ignoresSafeArea()
                        self.content()
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

public struct SearchableContentUnavailableModifier<OverlayContent: View, OverlaySearchContent: View, Result: Sendable & Emptyable>: ViewModifier {
    let state: LoadingState<Result>
    let content: () -> OverlayContent
    let searchContent: () -> OverlaySearchContent

    @Environment(\.isSearching) private var isSearching

    public func body(content: Content) -> some View {
        content
            .overlay {
                switch state {
                case let .result(result) where result.isEmpty:
                    ZStack {
                        Color.backgroundPrimary.ignoresSafeArea()
                        if isSearching {
                            searchContent()
                        } else {
                            self.content()
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
    func contentUnavailable<OverlayContent: View, OverlaySearchContent: View, Result: Sendable & Emptyable>(
        _ state: LoadingState<Result>,
        @ViewBuilder content: @escaping () -> OverlayContent,
        @ViewBuilder search searchContent: @escaping () -> OverlaySearchContent
    ) -> some View {
        modifier(
            SearchableContentUnavailableModifier(
                state: state,
                content: content,
                searchContent: searchContent
            )
        )
    }

    func contentUnavailable<OverlayContent: View, Result: Sendable & Emptyable>(
        _ state: LoadingState<Result>,
        @ViewBuilder content: @escaping () -> OverlayContent
    ) -> some View {
        modifier(
            ContentUnavailableModifier(
                state: state,
                content: content
            )
        )
    }

    func contentUnavailable<Actions: View, Result: Sendable & Emptyable>(
        _ state: LoadingState<Result>,
        image: Image? = nil,
        title: String = "Nothing Here",
        subtitle: String? = "There is no content to show",
        @ContentViewActionsBuilder actions: @escaping () -> Actions
    ) -> some View {
        modifier(
            ContentUnavailableModifier(
                state: state,
                content: {
                    EmptyStateView(
                        image: image,
                        title: title,
                        subtitle: subtitle,
                        actions: actions
                    )
                }
            )
        )
    }
}
