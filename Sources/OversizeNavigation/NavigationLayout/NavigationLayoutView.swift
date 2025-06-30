//
// Copyright © 2025 Alexander Romanov
// NavigationLayoutView.swift, created on 06.06.2025
//

import NavigatorUI
import OversizeUI
import SwiftUI

public struct NavigationLayoutView<
    Content: View,
    Background: View
>: View {
    @Environment(\.navigator) private var navigator

    @ViewBuilder private var content: Content
    @ViewBuilder private let background: Background

    private let title: String
    private let onScroll: LayoutView.ScrollAction?
    var backConfirmation: BackConfirmationContent?
    var isBackButtonHidden: Bool?

    @State private var isPresentBackConfirmation: Bool = false

    public var body: some View {
        LayoutView(
            title,
            onScroll: onScroll,
            content: { content },
            background: { background }
        )
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
        if let isBackButtonHidden = isBackButtonHidden, isBackButtonHidden {
            return false
        }
        if navigator.isPresented {
            if navigator.isEmpty {
                return true
            } else {
                return backConfirmation != nil
            }
        } else {
            return backConfirmation != nil
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
        _ title: String = "",
        onScroll: LayoutView.ScrollAction? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder background: () -> Background = { Color.backgroundPrimary }
    ) {
        self.title = title
        self.onScroll = onScroll
        self.content = content()
        self.background = background()
    }
}

#Preview {
    NavigationStack {
        NavigationLayoutView(
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
            background: { Color.backgroundSecondary }
        )
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NavigationLayoutView(
            "Title",
            content: { Text("Content") },
            background: { Color.backgroundSecondary }
        )
    }
}
