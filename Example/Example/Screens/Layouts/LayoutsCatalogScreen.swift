//
// Copyright © 2026 Alexander Romanov
// LayoutsCatalogScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct LayoutsCatalogScreen: View {
    @State private var openDestination: LayoutsDestinations?

    var body: some View {
        NavigationListLayout("Layouts") {
            Section("Every layout in the package") {
                ForEach(LayoutsDestinations.catalog) { destination in
                    ListRow(
                        destination.title,
                        subtitle: destination.subtitle,
                        action: { openDestination = destination }
                    )
                    .accessibilityIdentifier("layouts.\(destination.id)")
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        .backButtonHidden()
        .navigationOpen($openDestination)
        .accessibilityIdentifier("screen.Layouts")
    }
}

#Preview {
    LayoutsCatalogScreen()
}
