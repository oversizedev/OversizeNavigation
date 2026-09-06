//
// Copyright © 2026 Alexander Romanov
// NavigationListLayout.swift, created on 30.08.2026
//

import OversizeUI
import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct NavigationListLayout<
    Content: View,
    Background: View,
    SelectionValue: Hashable
>: View {
    @ViewBuilder private var content: Content
    @ViewBuilder private let background: Background

    @Binding private var selection: Set<SelectionValue>?

    private let title: String
    var backConfirmation: BackConfirmationContent?
    var isBackButtonHidden: Bool?
    var listStyle: ListLayoutStyle = .plain

    public var body: some View {
        listLayout
            .navigationLayoutBackToolbar(
                backConfirmation: backConfirmation,
                isBackButtonHidden: isBackButtonHidden
            )
    }

    @ViewBuilder
    private var listLayout: some View {
        #if os(watchOS)
            ListLayout(
                title,
                content: { content },
                background: { background }
            )
            .listLayoutStyle(listStyle)
        #else
            ListLayout(
                title,
                selection: $selection,
                content: { content },
                background: { background }
            )
            .listLayoutStyle(listStyle)
        #endif
    }

    // MARK: - Init

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
        _ title: String = "",
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

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("Plain") {
    NavigationStack {
        NavigationListLayout("Settings") {
            Section("General") {
                ForEach(1 ... 5, id: \.self) { item in
                    ListRow("Item \(item)")
                }
            }

            Section("Advanced") {
                ForEach(6 ... 10, id: \.self) { item in
                    ListRow("Item \(item)")
                }
            }
        }
        .toolbarTitleDisplayMode(.inline)
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *)
@available(watchOS, unavailable)
#Preview("Inset grouped with selection") {
    @Previewable @State var selection: Set<Int>? = []

    NavigationStack {
        NavigationListLayout("Settings", selection: $selection) {
            Section("General") {
                ForEach(1 ... 10, id: \.self) { item in
                    ListRow("Item \(item)")
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
    }
}
