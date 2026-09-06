//
// Copyright © 2026 Alexander Romanov
// ManagedCoverScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct ManagedCoverScreen: View {
    @State private var isDismissed: Bool = false

    var body: some View {
        NavigationCoverLayout(
            "Managed cover",
            coverHeight: 240,
            content: {
                Section("Inside the cover") {
                    Row(
                        "Dismiss",
                        subtitle: "navigationBack(to: .presentation)",
                        action: { isDismissed = true }
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
        // Substituted by a sheet on macOS, which has no title bar there.
        .accessibilityIdentifier("screen.Managed cover")
        .navigationBack($isDismissed, to: .presentation)
    }
}

#Preview {
    ManagedCoverScreen()
}
