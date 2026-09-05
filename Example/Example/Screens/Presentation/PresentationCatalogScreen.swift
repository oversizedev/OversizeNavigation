//
// Copyright © 2026 Alexander Romanov
// PresentationCatalogScreen.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import OversizeUI
import SwiftUI

struct PresentationCatalogScreen: View {
    @Environment(\.navigator) private var navigator

    var body: some View {
        NavigationListLayout("Presentation") {
            Section("Feedback surfaces") {
                ForEach(PresentationDestinations.catalog) { destination in
                    ListRow(
                        destination.title,
                        subtitle: destination.subtitle,
                        action: { navigator.navigate(to: destination) }
                    )
                    .accessibilityIdentifier("presentation.\(destination.id)")
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        .backButtonHidden()
    }
}

#Preview {
    PresentationCatalogScreen()
}
