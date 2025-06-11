//
// Copyright © 2025 Alexander Romanov
// PageView.swift, created on 01.06.2025
//

import OversizeUI
import ScrollKit
import SwiftUI

public typealias ScrollAction = @MainActor @Sendable (_ offset: CGPoint, _ headerVisibleRatio: CGFloat) -> Void

public struct PageView<
    Content: View,
    Background: View,
    EmptyContent: View
>: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.navigationPageStyle) private var style

    @ViewBuilder private var content: Content
    @ViewBuilder private let background: Background
    private var emptyContent: EmptyContent?

    private let title: String
    private let onScroll: ScrollAction?
    var logo: Image? = nil
    var isEmptyContent: Bool = false

    public var body: some View {
        Group {
            if isEmptyContent {
                emptyContent
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
            } else {
                ScrollView {
                    ScrollViewOffsetTracker {
                        content
                    }
                }
                .scrollViewOffsetTracking(action: handleScrollOffset)
            }
        }
        .navigationTitle(title)
        .background(background.ignoresSafeArea())
        .if(style == .default) {
            $0.toolbarBackground(Color.surfacePrimary, for: .navigationBar)
        }
    }

    private func handleScrollOffset(_ offset: CGPoint) {
        let calcHeaderHeight = 44 + screenSize.safeAreaTop
        let visibleRatio: CGFloat = (calcHeaderHeight + offset.y) / calcHeaderHeight
        onScroll?(offset, visibleRatio)
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
    NavigationView {
        PageView(
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
    NavigationView {
        PageView(
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
