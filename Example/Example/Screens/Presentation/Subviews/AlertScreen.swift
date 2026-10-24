//
// Copyright © 2026 Alexander Romanov
// AlertScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct AlertScreen: View {
    private struct DemoError: LocalizedError {
        var errorDescription: String? {
            "The demo request failed"
        }

        var failureReason: String? {
            "The example has no network layer"
        }

        var recoverySuggestion: String? {
            "Try one of the other cases"
        }
    }

    @State private var alert: AppAlert?
    @State private var hud: OversizeNavigation.HUD?
    @State private var lastAction: String = "None"

    var body: some View {
        NavigationLayout("Alerts") {
            Section("Last confirmed action") {
                Row("Result", subtitle: lastAction)
                    .accessibilityIdentifier("alert.result")
            }

            Section("Confirmations") {
                Row("Dismiss", action: { alert = .dismiss { confirm("dismiss") } })
                    .accessibilityIdentifier("alert.dismiss")

                Row("Delete", action: { alert = .delete { confirm("delete") } })
                    .accessibilityIdentifier("alert.delete")

                Row("Discard", action: { alert = .discard { confirm("discard") } })
                    .accessibilityIdentifier("alert.discard")

                Row("Unsaved changes", action: { alert = .unsavedChanges { confirm("unsavedChanges") } })
                    .accessibilityIdentifier("alert.unsavedChanges")

                Row(
                    "Destructive",
                    action: {
                        alert = .destructive(
                            "Remove the item?",
                            message: "This cannot be undone",
                            button: "Remove"
                        ) { confirm("destructive") }
                    }
                )
                .accessibilityIdentifier("alert.destructive")

                Row(
                    "Default",
                    action: {
                        alert = .default(
                            "Save the draft?",
                            message: "It will be kept on this device",
                            button: "Save"
                        ) { confirm("default") }
                    }
                )
                .accessibilityIdentifier("alert.default")
            }

            Section("Messages") {
                Row("Text", action: { alert = .text("Everything is up to date") })
                    .accessibilityIdentifier("alert.text")

                Row("Error", action: { alert = .error(DemoError()) })
                    .accessibilityIdentifier("alert.error")

                Row("App error", action: { alert = .appError(error: DemoError()) })
                    .accessibilityIdentifier("alert.appError")
            }
        } background: {
            Color.backgroundSecondary
        }
        .listLayoutStyle(.insetGrouped)
        .sectionBordered()
        .sectionTitlePosition(.inside)
        .sectionTitleSeparator(.visible)
        .presentationAlert($alert)
        .presentationHUD($hud)
        .accessibilityIdentifier("screen.Alerts")
    }

    private func confirm(_ name: String) {
        lastAction = name
        hud = .success("Confirmed \(name)")
    }
}

#Preview {
    AlertScreen()
}
