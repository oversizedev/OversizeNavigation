//
// Copyright © 2025 Alexander Romanov
// PageView.swift, created on 01.06.2025
//

import OversizeUI
import ScrollKit
import SwiftUI

public struct ListView<
    Content: View,
    Background: View,
    EmptyContent: View
>: View {
    @Environment(\.screenSize) private var screenSize

    @ViewBuilder private var content: Content
    @ViewBuilder private let background: Background
    private var emptyContent: EmptyContent?

    private let title: String
    var logo: Image? = nil
    var isEmptyContent: Bool = false

    public var body: some View {
        SwiftUI.Group {
            if isEmptyContent {
                emptyContent
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
            } else {
                SwiftUI.List { content }
            }
        }
        .navigationTitle(title)
        .background(background.ignoresSafeArea())
    }

    public init(
        _ title: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder background: () -> Background = { Color.backgroundPrimary },
        @ViewBuilder emptyContent: () -> EmptyContent = { EmptyView() }
    ) {
        self.title = title
        self.content = content()
        self.background = background()
        self.emptyContent = emptyContent()
    }
}

#Preview {
    NavigationView {
        ListView(
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
        ListView(
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
