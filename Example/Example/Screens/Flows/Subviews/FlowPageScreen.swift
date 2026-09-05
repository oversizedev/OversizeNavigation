//
// Copyright © 2026 Alexander Romanov
// FlowPageScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct FlowPageScreen: View {
    let number: Int

    @Environment(\.navigationInfo) private var navigationInfo

    @State private var isBackTriggered: Bool = false
    @State private var isReturningToFlows: Bool = false
    @State private var openDestination: FlowsDestinations?
    @State private var moveDestination: FlowsDestinations?
    @State private var hud: OversizeNavigation.HUD?

    var body: some View {
        NavigationLayout("Page \(number)") {
            Section("Where am I") {
                Row("Depth", subtitle: "Pushed \(navigationInfo.depth) deep")
                    .accessibilityIdentifier("page.depth")
            }

            Section("Go deeper") {
                NavigationLink(to: FlowsDestinations.page(number + 1)) {
                    Row("Push page \(number + 1)", subtitle: "NavigationLink(to:)")
                }
                .accessibilityIdentifier("page.push")

                Row(
                    "Open page \(number + 1)",
                    subtitle: "navigationOpen from a pushed screen",
                    action: { openDestination = .page(number + 1) }
                )
                .accessibilityIdentifier("page.open")

                Row(
                    "Move to page \(number + 1)",
                    subtitle: "navigationMove from a pushed screen",
                    action: { moveDestination = .page(number + 1) }
                )
                .accessibilityIdentifier("page.move")
            }

            Section("Present from here") {
                Row(
                    "Managed sheet",
                    subtitle: "A pushed screen presents on the root navigator",
                    action: { openDestination = .sheet }
                )
                .accessibilityIdentifier("page.sheet")
            }

            Section("Go back") {
                Row(
                    "Pop with navigationBack",
                    subtitle: "State-driven pop",
                    action: { isBackTriggered = true }
                )
                .accessibilityIdentifier("page.back")

                Row(
                    "Pop and show a HUD",
                    subtitle: "Both in the same state update",
                    action: {
                        hud = .delete()
                        isBackTriggered = true
                    }
                )
                .accessibilityIdentifier("page.backWithHUD")

                Row(
                    "Return to the flows root",
                    subtitle: "Checkpoint, no matter how deep",
                    action: { isReturningToFlows = true }
                )
                .disabled(navigationInfo.canReturn(to: KnownCheckpoints.flows) == false)
                .accessibilityIdentifier("page.checkpoint")
            }
        }
        .sectionTitlePosition(.inside)
        .navigationBack($isBackTriggered)
        .navigationReturn(to: KnownCheckpoints.flows, trigger: $isReturningToFlows)
        .navigationOpen($openDestination)
        .navigationMove($moveDestination)
        .presentationHUD($hud)
    }
}

#Preview {
    FlowPageScreen(number: 1)
}
