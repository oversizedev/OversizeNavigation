//
// Copyright © 2026 Alexander Romanov
// NavigationLayoutScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct NavigationLayoutScreen: View {
    @State private var offset: CGFloat = 0
    @State private var headerVisibleRatio: CGFloat = 1

    var body: some View {
        NavigationLayout(
            "NavigationLayout",
            onScroll: { offset, headerVisibleRatio in
                self.offset = offset
                self.headerVisibleRatio = headerVisibleRatio
            },
            content: {
                Section("Scroll position") {
                    Row("Offset", subtitle: String(format: "%.1f", offset))
                        .accessibilityIdentifier("navigationLayout.offset")
                    Row("Header visible", subtitle: String(format: "%.2f", headerVisibleRatio))
                }

                Section("Content") {
                    ForEach(1 ... 20, id: \.self) { item in
                        Row("Row \(item)", subtitle: "Plain scrollable content")
                    }
                }
            },
            background: { Color.backgroundSecondary }
        )
        .sectionTitlePosition(.inside)
        .bordered()
    }
}

#Preview {
    NavigationLayoutScreen()
}
