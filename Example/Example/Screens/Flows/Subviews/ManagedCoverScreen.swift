//
// Copyright © 2026 Alexander Romanov
// ManagedCoverScreen.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import OversizeUI
import SwiftUI

struct ManagedCoverScreen: View {
    @Environment(\.navigator) private var navigator

    var body: some View {
        NavigationCoverLayout(
            "Managed cover",
            coverHeight: 240,
            content: {
                Section("Inside the cover") {
                    Row(
                        "Dismiss",
                        subtitle: "navigator.dismiss()",
                        action: { navigator.dismiss() }
                    )
                    .accessibilityIdentifier("cover.dismiss")
                }
            },
            cover: {
                Text("Full screen")
                    .title()
                    .foregroundStyle(.white)
            },
            coverBackground: { Color.orange }
        )
        .sectionTitlePosition(.inside)
    }
}

#Preview {
    ManagedCoverScreen()
}
