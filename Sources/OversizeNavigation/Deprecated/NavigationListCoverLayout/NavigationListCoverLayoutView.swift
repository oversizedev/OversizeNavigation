//
// Copyright © 2025 Alexander Romanov
// NavigationListCoverLayoutView.swift, created on 06.05.2026
//

import NavigatorUI
import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct NavigationListCoverLayoutView<
    Content: View,
    Cover: View,
    CoverBackground: View,
    Background: View,
    SelectionValue: Hashable
>: View {
    @Environment(\.navigator) private var navigator

    @ViewBuilder private var content: Content
    @ViewBuilder private let cover: Cover
    @ViewBuilder private let coverBackground: CoverBackground
    @ViewBuilder private let background: Background

    private let title: String
    private let coverHeight: CGFloat

    @Binding private var selection: Set<SelectionValue>?

    var backConfirmation: BackConfirmationContent?
    var isBackButtonHidden: Bool?
    var listStyle: ListLayoutStyle = .plain
    var coverSpacing: CGFloat?

    @State private var isBackConfirmationPresented: Bool = false

    public var body: some View {
        listCoverLayout
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
    private var listCoverLayout: some View {
        #if os(watchOS)
            ListCoverLayoutView(
                title,
                coverHeight: coverHeight,
                content: { content },
                cover: { cover },
                coverBackground: { coverBackground },
                background: { background }
            )
            .listLayoutStyle(listStyle)
            .coverSpacing(coverSpacing)
        #else
            ListCoverLayoutView(
                title,
                coverHeight: coverHeight,
                selection: $selection,
                content: { content },
                cover: { cover },
                coverBackground: { coverBackground },
                background: { background }
            )
            .listLayoutStyle(listStyle)
            .coverSpacing(coverSpacing)
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

    private var isInteractiveBackDisabled: Bool {
        backConfirmation != nil
    }

    private var isNavigationBarBackButtonHidden: Bool {
        backConfirmation != nil || isBackButtonAtRootHidden
    }

    private var isBackButtonAtRootHidden: Bool {
        isBackButtonHidden == true && navigator.count == 0
    }

    private var isShowBackButton: Bool {
        if isBackButtonAtRootHidden {
            return false
        }
        if navigator.isPresented {
            if navigator.count == 0 {
                return true
            } else {
                return backConfirmation != nil
            }
        } else {
            return backConfirmation != nil
        }
    }

    private var backImage: Image {
        if navigator.isPresented, navigator.count == 0 {
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

    // MARK: - Init

    public init(
        _ title: String = "",
        coverHeight: CGFloat = 300,
        @ViewBuilder content: () -> Content,
        @ViewBuilder cover: () -> Cover,
        @ViewBuilder coverBackground: () -> CoverBackground = { Color.backgroundSecondary },
        @ViewBuilder background: () -> Background = { EmptyView() }
    ) where SelectionValue == Never {
        self.title = title
        self.coverHeight = coverHeight
        self.content = content()
        self.cover = cover()
        self.coverBackground = coverBackground()
        self.background = background()
        _selection = .constant(nil)
    }

    @available(watchOS, unavailable)
    public init(
        _ title: String = "",
        coverHeight: CGFloat = 300,
        selection: Binding<Set<SelectionValue>?>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder cover: () -> Cover,
        @ViewBuilder coverBackground: () -> CoverBackground = { Color.backgroundSecondary },
        @ViewBuilder background: () -> Background = { EmptyView() }
    ) {
        self.title = title
        self.coverHeight = coverHeight
        self.content = content()
        self.cover = cover()
        self.coverBackground = coverBackground()
        self.background = background()
        _selection = selection
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension NavigationListCoverLayoutView {
    func coverSpacing(_ spacing: CGFloat) -> Self {
        var view = self
        view.coverSpacing = spacing
        return view
    }
}

@available(iOS 18.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Basic") {
    NavigationStack {
        NavigationListCoverLayoutView("Albums") {
            ForEach(1 ... 30, id: \.self) { item in
                Text("Item \(item)")
            }
        } cover: {
            ZStack {
                Color.red.opacity(0.1)
                Text("Cover")
            }
        } coverBackground: {
            LinearGradient(
                colors: [Color.surfacePrimary, Color.yellow],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .toolbarTitleDisplayMode(.inline)
    }
}

@available(iOS 18.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Inset grouped") {
    NavigationStack {
        NavigationListCoverLayoutView("Albums", coverHeight: 200) {
            ForEach(1 ... 30, id: \.self) { item in
                Text("Item \(item)")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } cover: {
            Color.clear
        } coverBackground: {
            Color.indigo
        }
        .listLayoutStyle(.insetGrouped)
    }
}
