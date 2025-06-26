//
// Copyright © 2025 Alexander Romanov
// CoverPageView.swift, created on 01.06.2025
//

import OversizeUI
import ScrollKit
import SwiftUI

public enum CoverNavigationType {
    case `static`, prallax, pinch
}

public struct CoverPageView<
    Content: View,
    Cover: View,
    Background: View,
    EmptyContent: View
>: View {
    @Environment(\.screenSize) private var screenSize

    @ViewBuilder private var content: Content
    @ViewBuilder private let cover: Cover
    @ViewBuilder private let background: Background
    private var emptyContent: EmptyContent?

    private let title: String
    private let coverHeight: CGFloat
    private let onScroll: ScrollAction?
    var logo: Image? = nil
    var isEmptyContent: Bool = false
    var coverStyle: CoverNavigationType = .static
    var contentCornerRadius: CGFloat = 0

    @State private var scrollOffset: CGPoint = .zero

    public var body: some View {
        ZStack(alignment: .top) {
            cover
                .ignoresSafeArea(edges: .top)
                .frame(height: coverScrollHeight)
                .offset(y: coverScrollOffset)

            ScrollView {
                ScrollViewOffsetTracker {
                    content
                        .background {
                            background
                                .ignoresSafeArea()
                                .cornerRadius(
                                    contentCornerRadius,
                                    corners: [
                                        .topLeft,
                                        .topRight,
                                    ]
                                )
                        }
                        .padding(.top, contentTopPadding)
                }
            }
        }
        .opacity(isEmpty ? 0 : 1)
        .if(isEmpty) { _ in
            emptyContent
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
        }
        .contentMargins(.top, coverHeight, for: .scrollIndicators)
        .navigationTitle(title)
        .background(background.ignoresSafeArea())
        .scrollViewOffsetTracking(action: handleScrollOffset)
    }

    private var coverScrollHeight: CGFloat {
        switch coverStyle {
        case .pinch:
            if scrollOffset.y > 0 {
                return coverHeight + scrollOffset.y
            } else {
                let dampingFactor: CGFloat = 0.8
                return max(0, coverHeight + (scrollOffset.y * dampingFactor))
            }
        default:
            return scrollOffset.y > 0 ? coverHeight + scrollOffset.y : coverHeight
        }
    }

    private var coverScrollOffset: CGFloat {
        switch coverStyle {
        case .prallax:
            scrollOffset.y < 0 ? scrollOffset.y / 2 : 0
        default:
            0
        }
    }

    private var contentTopPadding: CGFloat {
        contentCornerRadius == 0 ? coverHeight : coverHeight - (contentCornerRadius * 1.4)
    }

    private func handleScrollOffset(_ offset: CGPoint) {
        scrollOffset = offset
        let calcHeaderHeight = 44 + screenSize.safeAreaTop
        let visibleRatio: CGFloat = (calcHeaderHeight + offset.y) / calcHeaderHeight
        onScroll?(offset, visibleRatio)
    }

    public init(
        _ title: String,
        coverHeight: CGFloat = 350,
        onScroll: ScrollAction? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder cover: () -> Cover,
        @ViewBuilder background: () -> Background = { Color.backgroundPrimary },
        @ViewBuilder emptyContent: () -> EmptyContent = { EmptyView() }
    ) {
        self.title = title
        self.coverHeight = coverHeight
        self.onScroll = onScroll
        self.content = content()
        self.cover = cover()
        self.background = background()
        self.emptyContent = emptyContent()
    }
}

#Preview("Static") {
    CoverPageView("Title") {
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
    } cover: {
        LinearGradient(
            colors: [
                Color.surfacePrimary,
                Color.yellow,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    } background: {
        Color.surfacePrimary
    }
    .coverStyle(.static)
}

#Preview("Parallax") {
    CoverPageView("Title") {
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
    } cover: {
        LinearGradient(
            colors: [
                Color.surfacePrimary,
                Color.yellow,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    } background: {
        Color.surfacePrimary
    }
    .coverStyle(.prallax)
}

#Preview("Pinch") {
    CoverPageView("Title") {
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
    } cover: {
        LinearGradient(
            colors: [
                Color.surfacePrimary,
                Color.yellow,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    } background: {
        Color.surfacePrimary
    }
    .coverStyle(.pinch)
}

#Preview("Title large") {
    NavigationStack {
        CoverPageView(
            "Title large",
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
                Color.red
            }
        )
    }
}

#Preview("Title and subtitle, large") {
    CoverPageView(
        "Title large",
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
            Color.red
        }
    )
}

#Preview {
    CoverPageView(
        "Title",
        content: { Text("Content") },
        cover: { Image("cover") },
        background: { Color.blue }
    )
}

#Preview {
    CoverPageView(
        "Title",
        content: { Text("Content") },
        cover: { Image("cover") }
    )
    .toolbar {
        ToolbarItem(placement: .confirmationAction) {
            Button("Cancel") {}
        }
    }
}
