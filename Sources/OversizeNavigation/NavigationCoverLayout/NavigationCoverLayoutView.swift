//
// Copyright © 2025 Alexander Romanov
// NavigationCoverLayoutView.swift, created on 06.06.2025
//

import NavigatorUI
import OversizeUI
import SwiftUI

public struct NavigationCoverLayoutView<
    Content: View,
    Cover: View,
    Background: View
>: View {
    @Environment(\.navigator) private var navigator

    @ViewBuilder private var content: Content
    @ViewBuilder private let cover: Cover
    @ViewBuilder private let background: Background

    private let title: String
    private let coverHeight: CGFloat
    private let onScroll: CoverLayoutView.ScrollAction?
    var backConfirmation: BackConfirmationContent?
    var coverStyle: CoverNavigationType = .static
    var contentCornerRadius: CGFloat = 0

    @State private var isBackConfirmationPresented: Bool = false

    public var body: some View {
        CoverLayoutView(
            title,
            coverHeight: coverHeight,
            onScroll: onScroll,
            content: { content },
            cover: { cover },
            background: { background }
        )
        .coverStyle(coverStyle)
        .contentCornerRadius(contentCornerRadius)
        .toolbar {
            if isShowBackButton {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: handleBackButtonTap) {
                        backImage.icon()
                    }
                    .confirmationDialog(
                        backConfirmation?.title ?? "Are you sure?",
                        isPresented: $isBackConfirmationPresented,
                        titleVisibility: .visible,
                        presenting: backConfirmation,
                        actions: { details in
                            Button(
                                details.confirmationButtonTitle,
                                action: handleConfirmationBackTap
                            )
                            Button(
                                details.cancelButtonTitle ?? "Cancel",
                                role: .cancel,
                                action: handleConfirmationCancelTap
                            )
                        },
                        message: { details in
                            Text(details.message)
                        }
                    )
                }
            }
        }
        .interactiveDismissDisabled(isInteractiveBackDisabled)
        .navigationBarBackButtonHidden(isNavigationBarBackButtonHidden)
    }

    private func handleBackButtonTap() {
        if backConfirmation == nil {
            navigator.back()
        } else {
            isBackConfirmationPresented = true
        }
    }

    private func handleConfirmationBackTap() {
        isBackConfirmationPresented = false
        navigator.back()
    }

    private func handleConfirmationCancelTap() {
        isBackConfirmationPresented = false
    }

    // MARK: - Deprecated methods for backward compatibility
    @available(*, deprecated, renamed: "handleBackButtonTap")
    private func onTapBackButton() {
        handleBackButtonTap()
    }

    @available(*, deprecated, renamed: "handleConfirmationBackTap")
    private func onTapConfirmationBack() {
        handleConfirmationBackTap()
    }

    @available(*, deprecated, renamed: "handleConfirmationCancelTap")
    private func onTapConfirmationCancel() {
        handleConfirmationCancelTap()
    }

    private var isInteractiveBackDisabled: Bool {
        backConfirmation != nil
    }

    private var isNavigationBarBackButtonHidden: Bool {
        backConfirmation != nil
    }

    private var isShowBackButton: Bool {
        if navigator.isPresented {
            true
        } else {
            backConfirmation != nil
        }
    }

    private var backImage: Image {
        if navigator.isPresented, navigator.isEmpty {
            Image.Base.close
        } else {
            Image.Base.chevronLeft
        }
    }

    public init(
        _ title: String,
        coverHeight: CGFloat = 350,
        onScroll: CoverLayoutView.ScrollAction? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder cover: () -> Cover,
        @ViewBuilder background: () -> Background = { Color.backgroundPrimary }
    ) {
        self.title = title
        self.coverHeight = coverHeight
        self.onScroll = onScroll
        self.content = content()
        self.cover = cover()
        self.background = background()
    }
}

#Preview {
    NavigationStack {
        NavigationCoverLayoutView(
            "Title",
            content: {
                LazyVStack(spacing: 0) {
                    ForEach(1 ... 100, id: \.self) { item in
                        Button {} label: {
                            VStack(spacing: 0) {
                                Text("Item \(item)")
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Divider()
                            }
                            .clipShape(Rectangle())
                        }
                    }
                }
            },
            cover: {
                Color.blue.overlay {
                    Rectangle()
                        .stroke(Color.red, lineWidth: 2)
                }
            },
            background: { Color.backgroundSecondary }
        )
        .coverStyle(.parallax)
        .toolbarTitleDisplayMode(.inline)
    }
}
