//
// Copyright © 2026 Alexander Romanov
// FlowsCatalogScreen.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import OversizeUI
import SwiftUI

struct FlowsCatalogScreen: View {
    @Environment(\.navigator) private var navigator

    @State private var openDestination: FlowsDestinations?
    @State private var moveDestination: FlowsDestinations?
    @State private var checkpointResult: Int?

    var body: some View {
        NavigationListLayout("Flows") {
            Section("Push") {
                ListRow(
                    "navigator.navigate(to:)",
                    subtitle: "Imperative push",
                    action: { navigator.navigate(to: FlowsDestinations.page(1)) }
                )
                .accessibilityIdentifier("flows.navigate")

                ListRow(
                    "navigationOpen",
                    subtitle: "Local and deterministic, stays on this stack",
                    action: { openDestination = .page(1) }
                )
                .accessibilityIdentifier("flows.open")

                ListRow(
                    "navigationMove",
                    subtitle: "Broadcast, resolved by the receiving stack",
                    action: { moveDestination = .page(1) }
                )
                .accessibilityIdentifier("flows.move")
            }

            Section("Presentation") {
                ListRow(
                    "Managed sheet",
                    subtitle: "Destination declares .managedSheet",
                    action: { navigator.navigate(to: FlowsDestinations.sheet) }
                )
                .accessibilityIdentifier("flows.sheet")

                ListRow(
                    "Managed cover",
                    subtitle: "Destination declares .managedCover",
                    action: { navigator.navigate(to: FlowsDestinations.cover) }
                )
                .accessibilityIdentifier("flows.cover")

                ListRow(
                    "Locked screen",
                    subtitle: "navigationLocked blocks dismissAny",
                    action: { navigator.navigate(to: FlowsDestinations.locked) }
                )
                .accessibilityIdentifier("flows.locked")
            }

            Section("Checkpoints") {
                ListRow(
                    "Return a value",
                    subtitle: checkpointResult.map { "Last result: \($0)" } ?? "No result yet",
                    action: { navigator.navigate(to: FlowsDestinations.checkpointResult) }
                )
                .accessibilityIdentifier("flows.checkpointResult")
            }

            Section("Deep links") {
                ListRow(
                    "Send to the HUD screen",
                    subtitle: "Switches tab, then pushes",
                    action: { navigator.send(RootTabs.presentation, PresentationDestinations.hud) }
                )
                .accessibilityIdentifier("flows.sendHUD")

                ListRow(
                    "Route to About",
                    subtitle: "One router for URLs and buttons",
                    action: { navigator.perform(route: ExampleRoutes.about) }
                )
                .accessibilityIdentifier("flows.routeAbout")

                ListRow(
                    "Route two pages deep",
                    subtitle: "A route may need several steps",
                    action: { navigator.perform(route: ExampleRoutes.deepPage) }
                )
                .accessibilityIdentifier("flows.routeDeep")
            }
        }
        .listLayoutStyle(.insetGrouped)
        .backButtonHidden()
        .navigationCheckpoint(KnownCheckpoints.flowsResult, completion: { result in
            checkpointResult = result
        })
        .navigationOpen($openDestination)
        .navigationMove($moveDestination)
    }
}

#Preview {
    FlowsCatalogScreen()
}
