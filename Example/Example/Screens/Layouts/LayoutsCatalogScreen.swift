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
        NavigationLayout("Layouts") {
            Section("Every layout in the package") {
                ForEach(LayoutsDestinations.catalog) { destination in
                    Row(
                        destination.title,
                        subtitle: destination.subtitle,
                        action: { openDestination = destination }
                    )
                    .accessibilityIdentifier("layouts.\(destination.id)")
                }
            }
        } background: {
            Color.backgroundSecondary
        }
        .listLayoutStyle(.insetGrouped)
        .sectionBordered()
        .sectionTitlePosition(.inside)
        .sectionTitleSeparator(.visible)
        .navigationOpen($openDestination)
        .accessibilityIdentifier("screen.Layouts")
    }
}

#Preview {
    LayoutsCatalogScreen()
}
