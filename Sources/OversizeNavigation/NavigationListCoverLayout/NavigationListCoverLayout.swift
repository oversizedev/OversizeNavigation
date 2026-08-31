//
// Copyright © 2026 Alexander Romanov
// NavigationListCoverLayout.swift, created on 30.08.2026
//

import NavigatorUI
import OversizeUI
import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct NavigationListCoverLayout<
    Content: View,
    Cover: View,
    CoverBackground: View,
    Background: View,
    SelectionValue: Hashable
>: View {
    @ViewBuilder private var content: Content
    @ViewBuilder private let cover: Cover
    @ViewBuilder private let coverBackground: CoverBackground
    @ViewBuilder private let background: Background

    @Binding private var selection: Set<SelectionValue>?

    private let title: String
    private let coverHeight: CGFloat
    var backConfirmation: BackConfirmationContent?
    var isBackButtonHidden: Bool?
    var listStyle: ListLayoutStyle = .plain
    var coverSpacing: CGFloat?

    public var body: some View {
        listCoverLayout
            .navigationLayoutBackToolbar(
                backConfirmation: backConfirmation,
                isBackButtonHidden: isBackButtonHidden
            )
    }

    @ViewBuilder
    private var listCoverLayout: some View {
        #if os(watchOS)
            ListCoverLayout(
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
            ListCoverLayout(
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

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("Basic") {
    NavigationStack {
        NavigationListCoverLayout("Albums") {
            Section("Recently added") {
                ForEach(1 ... 10, id: \.self) { item in
                    ListRow("Item \(item)")
                }
            }

            Section("Favorites") {
                ForEach(11 ... 30, id: \.self) { item in
                    ListRow("Item \(item)")
                }
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

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("Inset grouped") {
    NavigationStack {
        NavigationListCoverLayout("Albums", coverHeight: 200) {
            Section("Section") {
                ForEach(1 ... 30, id: \.self) { item in
                    ListRow("Item \(item)")
                }
            }
        } cover: {
            Color.clear
        } coverBackground: {
            Color.indigo
        }
        .listLayoutStyle(.insetGrouped)
    }
}
