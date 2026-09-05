//
// Copyright © 2026 Alexander Romanov
// LayoutsCatalogScreen.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import OversizeUI
import SwiftUI

struct LayoutsCatalogScreen: View {
    @Environment(\.navigator) private var navigator

    var body: some View {
        NavigationListLayout("Layouts") {
            Section("Every layout in the package") {
                ForEach(LayoutsDestinations.catalog) { destination in
                    ListRow(
                        destination.title,
                        subtitle: destination.subtitle,
                        action: { navigator.navigate(to: destination) }
                    )
                    .accessibilityIdentifier("layouts.\(destination.id)")
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        .backButtonHidden()
    }
}

#Preview {
    LayoutsCatalogScreen()
}
