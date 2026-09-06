//
// Copyright © 2026 Alexander Romanov
// ManagedSheetScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

/// A managed sheet carries its own stack, so the layout shows a close button at its root and a
/// back chevron on anything pushed on top of it.
struct ManagedSheetScreen: View {
    @State private var openDestination: FlowsDestinations?
    @State private var isDismissed: Bool = false

    var body: some View {
        NavigationListLayout("Managed sheet") {
            Section("Inside the sheet") {
                ListRow(
                    "Push inside the sheet",
                    subtitle: "The close button becomes a chevron",
                    action: { openDestination = .page(1) }
                )
                .accessibilityIdentifier("sheet.push")

                ListRow(
                    "Dismiss",
                    subtitle: "navigationBack(to: .presentation)",
                    action: { isDismissed = true }
                )
                .accessibilityIdentifier("sheet.dismiss")
            }
        }
        .listLayoutStyle(.insetGrouped)
        // macOS gives a sheet no title bar, so `navigationTitle` is published nowhere and the UI
        // tests cannot tell which sheet is on screen without the screen naming itself.
        .accessibilityIdentifier("screen.Managed sheet")
        .navigationOpen($openDestination)
        .navigationBack($isDismissed, to: .presentation)
    }
}

#Preview {
    ManagedSheetScreen()
}
