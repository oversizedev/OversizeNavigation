//
// Copyright © 2026 Alexander Romanov
// NavigationLayout.swift, created on 26.06.2026
//

import OversizeUI
import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct NavigationLayout<
    Content: View,
    Background: View
>: View {
    public typealias ScrollAction = @MainActor @Sendable (_ offset: CGFloat, _ headerVisibleRatio: CGFloat) -> Void

    @ViewBuilder private var content: Content
    @ViewBuilder private let background: Background

    private let title: String
    private let onScroll: ScrollAction?
    var backConfirmation: BackConfirmationContent?
    var isBackButtonHidden: Bool?

    public var body: some View {
        OversizeUI.Layout(
            title,
            onScroll: onScroll,
            content: { content },
            background: { background }
        )
        .navigationLayoutBackToolbar(
            backConfirmation: backConfirmation,
            isBackButtonHidden: isBackButtonHidden
        )
    }

    public init(
        _ title: String = "",
        onScroll: ScrollAction? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder background: () -> Background = { Color.backgroundSecondary }
    ) {
        self.title = title
        self.onScroll = onScroll
        self.content = content()
        self.background = background()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview {
    NavigationStack {
        NavigationLayout("Albums") {
            Section {
                Text("Song 1").padding()
                Text("Song 2").padding()
            }
            Section("Favorites") {
                Row("Song 1") { print("") }
                Row("Song 2")
                Row("Song 3") { print("") }
            }
        }
        .sectionTitlePosition(.inside)
        .bordered()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview {
    NavigationStack {
        NavigationLayout("Empty") {
            Text("Content")
        }
    }
}
