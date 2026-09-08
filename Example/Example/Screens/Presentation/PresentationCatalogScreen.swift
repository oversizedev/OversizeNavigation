//
// Copyright © 2026 Alexander Romanov
// PresentationCatalogScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct PresentationCatalogScreen: View {
    @State private var openDestination: PresentationDestinations?

    var body: some View {
        NavigationListLayout("Presentation") {
            Section("Feedback surfaces") {
                ForEach(PresentationDestinations.catalog) { destination in
                    ListRow(
                        destination.title,
                        subtitle: destination.subtitle,
                        action: { openDestination = destination }
                    )
                    .accessibilityIdentifier("presentation.\(destination.id)")
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        .backButtonHidden()
        .navigationOpen($openDestination)
        .accessibilityIdentifier("screen.Presentation")
    }
}

#Preview {
    PresentationCatalogScreen()
}
