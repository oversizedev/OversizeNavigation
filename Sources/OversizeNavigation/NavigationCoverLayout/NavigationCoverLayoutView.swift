//
// Copyright © 2025 Alexander Romanov
// PageView.swift, created on 06.06.2025
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
    var logo: Image? = nil
    var backConfirmation: BackConfirmationContent?
    var coverStyle: CoverNavigationType = .static
    var contentCornerRadius: CGFloat = 0

    @State private var isPresentBackConfirmation: Bool = false

    public var body: some View {
        CoverLayoutView(
            title,
            coverHeight: coverHeight,
            onScroll: onScroll,
            content: { content },
            cover: { cover },
            background: { background }
        )
        .toolbarImage(logo)
        .coverStyle(coverStyle)
        .contentCornerRadius(contentCornerRadius)
        .toolbar {
            if isShowBackButton {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: onTapBackButton) {
                        backImage.icon()
                    }
                    .confirmationDialog(
                        backConfirmation?.title ?? "Are you sure?",
                        isPresented: $isPresentBackConfirmation,
                        titleVisibility: .visible,
                        presenting: backConfirmation,
                        actions: { details in
                            Button(
                                details.confirmationButtonTitle,
                                action: onTapConfirmationBack
                            )
                            Button(
                                details.cancelButtonTitle ?? "Cancel",
                                role: .cancel,
                                action: onTapConfirmationCancel
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

    private func onTapBackButton() {
        if backConfirmation == nil {
            navigator.back()
        } else {
            isPresentBackConfirmation = true
        }
    }

    private func onTapConfirmationBack() {
        isPresentBackConfirmation = false
        navigator.back()
    }

    private func onTapConfirmationCancel() {
        isPresentBackConfirmation = false
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
        .coverStyle(.prallax)
        .toolbarTitleDisplayMode(.inline)
    }
}
