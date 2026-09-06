//
// Copyright © 2025 Alexander Romanov
// NavigationListLayoutView.swift, created on 06.06.2025
//

import NavigatorUI
import OversizeUI
import SwiftUI

@available(iOS, introduced: 17.0, deprecated: 18.0, renamed: "NavigationListLayout")
@available(macOS, introduced: 14.0, deprecated: 15.0, renamed: "NavigationListLayout")
@available(tvOS, introduced: 17.0, deprecated: 18.0, renamed: "NavigationListLayout")
@available(watchOS, introduced: 10.0, deprecated: 11.0, renamed: "NavigationListLayout")
@available(visionOS, introduced: 1.0, deprecated: 2.0, renamed: "NavigationListLayout")
public struct NavigationListLayoutView<
    Content: View,
    Background: View,
    SelectionValue: Hashable
>: View {
    @Environment(\.navigator) private var navigator

    @ViewBuilder private var content: Content
    @ViewBuilder private let background: Background

    @Binding private var selection: Set<SelectionValue>?

    private let title: String
    var backConfirmation: BackConfirmationContent?
    var isBackButtonHidden: Bool?
    var listStyle: ListLayoutStyle = .plain

    @State private var isBackConfirmationPresented: Bool = false

    public var body: some View {
        listLayout
            .toolbar {
                if isShowBackButton {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel, action: handleBackButtonTap) {
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

    @ViewBuilder
    private var listLayout: some View {
        #if os(watchOS)
            ListLayoutView(
                title,
                content: { content },
                background: { background }
            )
            .listLayoutStyle(listStyle)
        #else
            ListLayoutView(
                title,
                selection: $selection,
                content: { content },
                background: { background }
            )
            .listLayoutStyle(listStyle)
        #endif
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

    private var backButtonPolicy: BackButtonPolicy {
        .init(
            isPresented: navigator.isPresented,
            count: navigator.count,
            isBackButtonHidden: isBackButtonHidden,
            hasBackConfirmation: backConfirmation != nil
        )
    }

    private var isInteractiveBackDisabled: Bool {
        backButtonPolicy.isInteractiveBackDisabled
    }

    private var isNavigationBarBackButtonHidden: Bool {
        backButtonPolicy.isNavigationBarBackButtonHidden
    }

    private var isShowBackButton: Bool {
        backButtonPolicy.isShowBackButton
    }

    private var backImage: Image {
        if backButtonPolicy.isPresentationRoot {
            if #available(macOS 26, iOS 26, tvOS 26, watchOS 26, *) {
                Image(systemName: "xmark")
            } else {
                Image.Base.close
            }
        } else {
            if #available(macOS 26, iOS 26, tvOS 26, watchOS 26, *) {
                Image(systemName: "chevron.left")
            } else {
                Image.Base.chevronLeft
            }
        }
    }

    public init(
        _ title: String = "",
        @ViewBuilder content: () -> Content,
        @ViewBuilder background: () -> Background = { EmptyView() }
    ) where SelectionValue == Never {
        self.title = title
        self.content = content()
        self.background = background()
        _selection = .constant(nil)
    }

    @available(watchOS, unavailable)
    public init(
        _ title: String,
        selection: Binding<Set<SelectionValue>?>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder background: () -> Background = { EmptyView() }
    ) {
        self.title = title
        self.content = content()
        self.background = background()
        _selection = selection
    }
}

#Preview {
    NavigationStack {
        NavigationListLayoutView(
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
        NavigationListLayoutView(
            "Title",
            content: { Text("Content") },
            background: { Color.backgroundSecondary }
        )
    }
}
