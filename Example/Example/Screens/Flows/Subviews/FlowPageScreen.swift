//
// Copyright © 2026 Alexander Romanov
// FlowPageScreen.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import OversizeUI
import SwiftUI

struct FlowPageScreen: View {
    let number: Int

    @Environment(\.navigator) private var navigator

    @State private var isBackTriggered: Bool = false

    var body: some View {
        NavigationLayout("Page \(number)") {
            Section("Where am I") {
                Row("Depth", subtitle: "\(navigator.count)")
                    .accessibilityIdentifier("page.depth")
            }

            Section("Go deeper") {
                NavigationLink(to: FlowsDestinations.page(number + 1)) {
                    Row("Push page \(number + 1)", subtitle: "NavigationLink(to:)")
                }
                .accessibilityIdentifier("page.push")
            }

            Section("Go back") {
                Row(
                    "Pop with navigationBack",
                    subtitle: "State-driven pop",
                    action: { isBackTriggered = true }
                )
                .accessibilityIdentifier("page.back")

                Row(
                    "Return to the flows root",
                    subtitle: "Checkpoint, no matter how deep",
                    action: { navigator.returnToCheckpoint(KnownCheckpoints.flows) }
                )
                .disabled(navigator.canReturnToCheckpoint(KnownCheckpoints.flows) == false)
                .accessibilityIdentifier("page.checkpoint")
            }
        }
        .sectionTitlePosition(.inside)
        .navigationBack($isBackTriggered)
    }
}

#Preview {
    FlowPageScreen(number: 1)
}
