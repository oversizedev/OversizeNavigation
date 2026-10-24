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
        NavigationLayout("Settings") {
            Section("Root layout") {
                Row(
                    "Switch tabs and split",
                    subtitle: "navigationMove broadcasts a value handled at the navigation root",
                    action: { toggleRootType = .init() }
                )
                .accessibilityIdentifier("settings.toggleRoot")
            }

            Section("About") {
                Row(
                    "About",
                    subtitle: "The target of the about route",
                    action: { openDestination = .about }
                )
                .accessibilityIdentifier("settings.about")
            }
        } background: {
            Color.backgroundSecondary
        }
        .listLayoutStyle(.insetGrouped)
        .sectionBordered()
        .sectionTitlePosition(.inside)
        .sectionTitleSeparator(.visible)
        .navigationOpen($openDestination)
        .navigationMove($toggleRootType)
        .accessibilityIdentifier("screen.Settings")
    }
}

#Preview {
    SettingsScreen()
}
