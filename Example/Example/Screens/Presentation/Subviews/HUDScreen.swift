//
// Copyright © 2026 Alexander Romanov
// HUDScreen.swift, created on 05.09.2026
//

import Foundation
import OversizeNavigation
import OversizeUI
import SwiftUI

/// `presentationHUDRoot()` is applied once at the app root; screens only publish values.
struct HUDScreen: View {
    private struct DemoError: LocalizedError {
        var errorDescription: String? {
            "The demo request failed"
        }
    }

    @Environment(\.hud) private var hudState

    @State private var hud: OversizeNavigation.HUD?

    private let samples: [(id: String, title: String, hud: OversizeNavigation.HUD)] = [
        ("success", "Success", .success()),
        ("destructive", "Destructive", .destructive()),
        ("delete", "Delete", .delete()),
        ("archive", "Archive", .archive()),
        ("unarchive", "Unarchive", .unarchive()),
        ("favorite", "Favorite", .favorite()),
        ("unfavorite", "Unfavorite", .unfavorite()),
        ("edited", "Edited", .edited()),
        ("text", "Custom text", .default("Copied to the clipboard")),
        ("error", "Error", .error(DemoError())),
    ]

    var body: some View {
        NavigationListLayout("HUD") {
            Section("Cases") {
                ForEach(samples, id: \.id) { sample in
                    ListRow(sample.title, action: { hud = sample.hud })
                        .accessibilityIdentifier("hud.\(sample.id)")
                }
            }

            Section("Stack") {
                ListRow(
                    "Present five in a row",
                    subtitle: "Only the three most recent stay on screen",
                    action: { presentMany() }
                )
                .accessibilityIdentifier("hud.stack")

                ListRow(
                    "Clear the stack",
                    subtitle: "Cancels every pending auto dismiss",
                    action: { hudState.clearAllHUDs() }
                )
                .accessibilityIdentifier("hud.clear")
            }
        }
        .listLayoutStyle(.insetGrouped)
        .presentationHUD($hud)
    }

    private func presentMany() {
        for index in 1 ... 5 {
            hudState.presentHUD(.default("HUD \(index)", duration: .seconds(4)))
        }
    }
}

#Preview {
    HUDScreen()
}
