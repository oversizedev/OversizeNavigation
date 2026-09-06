//
// Copyright © 2026 Alexander Romanov
// SettingsScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct SettingsScreen: View {
    @State private var openDestination: SettingsDestinations?
    @State private var toggleRootType: ToggleRootType?

    var body: some View {
        NavigationListLayout("Settings") {
            Section("Root layout") {
                ListRow(
                    "Switch tabs and split",
                    subtitle: "navigationMove broadcasts a value handled at the navigation root",
                    action: { toggleRootType = .init() }
                )
                .accessibilityIdentifier("settings.toggleRoot")
            }

            Section("About") {
                ListRow(
                    "About",
                    subtitle: "The target of the about route",
                    action: { openDestination = .about }
                )
                .accessibilityIdentifier("settings.about")
            }
        }
        .listLayoutStyle(.insetGrouped)
        .backButtonHidden()
        .navigationOpen($openDestination)
        .navigationMove($toggleRootType)
    }
}

#Preview {
    SettingsScreen()
}
