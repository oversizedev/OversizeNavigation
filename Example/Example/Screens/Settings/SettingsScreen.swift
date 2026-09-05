//
// Copyright © 2026 Alexander Romanov
// SettingsScreen.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import OversizeUI
import SwiftUI

struct SettingsScreen: View {
    @Environment(\.navigator) private var navigator

    var body: some View {
        NavigationListLayout("Settings") {
            Section("Root layout") {
                ListRow(
                    "Switch tabs and split",
                    subtitle: "Sent as a value, handled at the navigation root",
                    action: { navigator.send(ToggleRootType()) }
                )
                .accessibilityIdentifier("settings.toggleRoot")
            }

            Section("About") {
                ListRow(
                    "About",
                    subtitle: "The target of the about route",
                    action: { navigator.navigate(to: SettingsDestinations.about) }
                )
                .accessibilityIdentifier("settings.about")
            }
        }
        .listLayoutStyle(.insetGrouped)
        .backButtonHidden()
    }
}

#Preview {
    SettingsScreen()
}
