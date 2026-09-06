//
// Copyright © 2026 Alexander Romanov
// CoverLayoutScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct CoverLayoutScreen: View {
    private enum DemoCoverStyle: String, CaseIterable, Identifiable {
        case `static`
        case parallax
        case pinch

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .static: "Static"
            case .parallax: "Parallax"
            case .pinch: "Pinch"
            }
        }

        var style: CoverNavigationType {
            switch self {
            case .static: .static
            case .parallax: .parallax
            case .pinch: .pinch
            }
        }
    }

    @State private var demoStyle: DemoCoverStyle = .parallax

    var body: some View {
        NavigationCoverLayout(
            "NavigationCoverLayout",
            coverHeight: 280,
            content: {
                Section("Cover style") {
                    Picker("Cover style", selection: $demoStyle) {
                        ForEach(DemoCoverStyle.allCases) { style in
                            Text(style.title).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("coverLayout.style")
                }

                Section("Content") {
                    ForEach(1 ... 20, id: \.self) { item in
                        Row("Row \(item)")
                    }
                }
            },
            cover: {
                ZStack {
                    LinearGradient(
                        colors: [.indigo, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Text("Cover")
                        .title()
                        .foregroundStyle(.white)
                }
            },
            coverBackground: { Color.indigo }
        )
        .coverStyle(demoStyle.style)
        .contentCornerRadius(24)
        .contentOffset(-24)
        .sectionTitlePosition(.inside)
    }
}

#Preview {
    CoverLayoutScreen()
}
