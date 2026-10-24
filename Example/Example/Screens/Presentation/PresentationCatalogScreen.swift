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
        NavigationLayout("Presentation") {
            Section("Feedback surfaces") {
                ForEach(PresentationDestinations.catalog) { destination in
                    Row(
                        destination.title,
                        subtitle: destination.subtitle,
                        action: { openDestination = destination }
                    )
                    .accessibilityIdentifier("presentation.\(destination.id)")
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
        .accessibilityIdentifier("screen.Presentation")
    }
}

#Preview {
    PresentationCatalogScreen()
}
