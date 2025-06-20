//
// Copyright © 2025 Alexander Romanov
// PageView.swift, created on 06.06.2025
//

import NavigatorUI
import OversizeUI
import SwiftUI

public struct NavigationPageView<
    Content: View,
    Background: View,
    EmptyContent: View
>: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.navigationPageStyle) private var style

    @ViewBuilder private var content: Content
    @ViewBuilder private let background: Background

    private var emptyContent: EmptyContent?

    private let title: String
    private let onScroll: ScrollAction?
    var logo: Image? = nil
    var isEmptyContent: Bool = false
    var backConfirmation: BackConfirmationContent?

    @State private var isPresentBackConfirmation: Bool = false

    public var body: some View {
        PageView(
            title,
            onScroll: onScroll,
            content: { content },
            background: { background },
            emptyContent: { emptyContent }
        )
        .toolbarImage(logo)
        .emptyContent(isEmptyContent)
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
        /* Old iOS Version
         .alert(
             backConfirmation?.title ?? "Are you sure?",
             isPresented: $isPresentBackConfirmation,
             presenting: backConfirmation
         ) { details in
             Button(
                 details.confirmationButtonTitle,
                 action: onTapConfirmationBack
             )
             Button(
                 details.cancelButtonTitle ?? "Cancel",
                 role: .cancel,
                 action: onTapConfirmationCancel
             )
         } message: { details in
             Text(details.message)
         }
          */
        .interactiveDismissDisabled(isInteractiveBackDisabled)
        .navigationBarBackButtonHidden(isNavigationBarBackButtonHidden)
        #if os(iOS)
            .if(style != .native) {
                $0.interactivePopGestureDisabled(isInteractiveBackDisabled)
            }
        #endif
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
        switch style {
        case .default:
            true
        case .native:
            backConfirmation != nil
        }
    }

    private var isShowBackButton: Bool {
        if navigator.isPresented {
            true
        } else {
            switch style {
            case .default:
                !navigator.isEmpty
            case .native:
                backConfirmation != nil
            }
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
        onScroll: ScrollAction? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder background: () -> Background = { Color.backgroundPrimary },
        @ViewBuilder emptyContent: () -> EmptyContent = { EmptyView() }
    ) {
        self.title = title
        self.onScroll = onScroll
        self.content = content()
        self.background = background()
        self.emptyContent = emptyContent()
    }
}

#Preview {
    NavigationStack {
        NavigationPageView(
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
            background: { Color.backgroundSecondary },
            emptyContent: {
                VStack(spacing: 0) {
                    Text("No items available")
                        .foregroundStyle(Color.onBackgroundPrimary)
                        .padding()
                }
            }
        )
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NavigationPageView(
            "Title",
            content: { Text("Content") },
            background: { Color.backgroundSecondary },
            emptyContent: {
                VStack(spacing: 0) {
                    Text("No items available")
                        .foregroundStyle(Color.onBackgroundPrimary)
                        .padding()
                }
            }
        )
        .emptyContent(true)
    }
}
