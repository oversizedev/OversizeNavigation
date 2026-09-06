//
// Copyright © 2026 Alexander Romanov
// ListLayoutScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct ListLayoutScreen: View {
    /// `ListLayoutStyle` is not iterable, so the demo drives it through its own picker value.
    private enum DemoStyle: String, CaseIterable, Identifiable {
        case plain
        case inset
        case insetGrouped
        case smallInsetGrouped
        case grouped

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .plain: "Plain"
            case .inset: "Inset"
            case .insetGrouped: "Inset grouped"
            case .smallInsetGrouped: "Small inset grouped"
            case .grouped: "Grouped"
            }
        }

        var style: ListLayoutStyle {
            switch self {
            case .plain: .plain
            case .inset: .inset
            case .insetGrouped: .insetGrouped
            case .smallInsetGrouped: .smallInsetGrouped
            case .grouped: .grouped
            }
        }
    }

    @State private var demoStyle: DemoStyle = .insetGrouped

    var body: some View {
        NavigationListLayout("NavigationListLayout") {
            Section("Style") {
                Picker("Style", selection: $demoStyle) {
                    ForEach(DemoStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .accessibilityIdentifier("listLayout.style")
            }

            Section("Items") {
                ForEach(1 ... 20, id: \.self) { item in
                    ListRow("Item \(item)", subtitle: "Styled as \(demoStyle.title)")
                }
            }
        }
        .listLayoutStyle(demoStyle.style)
    }
}

#Preview {
    ListLayoutScreen()
}
