//
// Copyright © 2026 Alexander Romanov
// ManagedSheetScreen.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import OversizeUI
import SwiftUI

/// A managed sheet carries its own stack, so the layout shows a close button at its root and a
/// back chevron on anything pushed on top of it.
struct ManagedSheetScreen: View {
    @Environment(\.navigator) private var navigator

    var body: some View {
        NavigationListLayout("Managed sheet") {
            Section("Inside the sheet") {
                ListRow(
                    "Push inside the sheet",
                    subtitle: "The close button becomes a chevron",
                    action: { navigator.navigate(to: FlowsDestinations.page(1)) }
                )
                .accessibilityIdentifier("sheet.push")

                ListRow(
                    "Dismiss",
                    subtitle: "navigator.dismiss()",
                    action: { navigator.dismiss() }
                )
                .accessibilityIdentifier("sheet.dismiss")
            }
        }
        .listLayoutStyle(.insetGrouped)
    }
}

#Preview {
    ManagedSheetScreen()
}
