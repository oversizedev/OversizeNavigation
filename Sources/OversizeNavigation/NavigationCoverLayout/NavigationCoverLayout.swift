//
// Copyright © 2026 Alexander Romanov
// NavigationCoverLayout.swift, created on 26.06.2026
//

import NavigatorUI
import OversizeUI
import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct NavigationCoverLayout<
    Content: View,
    Cover: View,
    ContentBackground: View,
    CoverBackground: View,
    Background: View
>: View {
    public typealias ScrollAction = @MainActor @Sendable (_ offset: CGFloat, _ headerVisibleRatio: CGFloat) -> Void

    @Environment(\.navigator) private var navigator

    @ViewBuilder private var content: Content
    @ViewBuilder private let cover: Cover
    @ViewBuilder private let contentBackground: ContentBackground
    @ViewBuilder private let coverBackground: CoverBackground
    @ViewBuilder private let background: Background

    private let title: String
    private let coverHeight: CGFloat
    private let onScroll: ScrollAction?
    var backConfirmation: BackConfirmationContent?
    var isBackButtonHidden: Bool?
    var coverStyle: CoverNavigationType = .static
    var contentCornerRadius: CGFloat = 0
    var contentOffset: CGFloat = 0

    @State private var isBackConfirmationPresented: Bool = false

    public var body: some View {
        CoverLayout(
            title,
            coverHeight: coverHeight,
            onScroll: onScroll,
            content: { content },
            cover: { cover },
            contentBackground: { contentBackground },
            coverBackground: { coverBackground },
            background: { background }
        )
        .coverStyle(coverStyle)
        .contentCornerRadius(contentCornerRadius)
        .contentOffset(contentOffset)
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
        coverHeight: CGFloat = 300,
        onScroll: ScrollAction? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder cover: () -> Cover,
        @ViewBuilder contentBackground: () -> ContentBackground = { Color.backgroundPrimary },
        @ViewBuilder coverBackground: () -> CoverBackground = { Color.backgroundSecondary },
        @ViewBuilder background: () -> Background = { Color.backgroundPrimary }
    ) {
        self.title = title
        self.coverHeight = coverHeight
        self.onScroll = onScroll
        self.content = content()
        self.cover = cover()
        self.contentBackground = contentBackground()
        self.coverBackground = coverBackground()
        self.background = background()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview {
    NavigationStack {
        NavigationCoverLayout("Albums") {
            Section {
                Text("Song 1").padding()
                Text("Song 2").padding()
            }
            Section("Favorites") {
                Row("Song 1") { print("") }
                Row("Song 2")
                Row("Song 3") { print("") }
            }
        } cover: {
            LinearGradient(
                colors: [Color.surfacePrimary, Color.yellow],
                startPoint: .top,
                endPoint: .bottom
            )
        } coverBackground: {
            Color.red
        }
        .sectionTitlePosition(.inside)
        .bordered()
    }
}
