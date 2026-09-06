//
// Copyright © 2026 Alexander Romanov
// FlowsCatalogScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct FlowsCatalogScreen: View {
    @State private var openDestination: FlowsDestinations?
    @State private var moveDestination: FlowsDestinations?
    @State private var moveValues: [AnyHashable]?
    @State private var route: ExampleRoutes?
    @State private var checkpointResult: Int?

    var body: some View {
        NavigationListLayout("Flows") {
            Section("Push") {
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
                    action: { openDestination = .sheet }
                )
                .accessibilityIdentifier("flows.sheet")

                ListRow(
                    "Managed cover",
                    subtitle: "Destination declares .managedCover",
                    action: { openDestination = .cover }
                )
                .accessibilityIdentifier("flows.cover")

                ListRow(
                    "Locked screen",
                    subtitle: "navigationLocked blocks navigationDismissAny",
                    action: { openDestination = .locked }
                )
                .accessibilityIdentifier("flows.locked")
            }

            Section("Checkpoints") {
                ListRow(
                    "Return a value",
                    subtitle: checkpointResult.map { "Last result: \($0)" } ?? "No result yet",
                    action: { openDestination = .checkpointResult }
                )
                .accessibilityIdentifier("flows.checkpointResult")
            }

            Section("Deep links") {
                ListRow(
                    "Send to the HUD screen",
                    subtitle: "navigationMove(values:) switches tab, then pushes",
                    action: { moveValues = ExampleRoutes.hud.moveValues }
                )
                .accessibilityIdentifier("flows.sendHUD")

                ListRow(
                    "Route to About",
                    subtitle: "One router for URLs and buttons",
                    action: { route = .about }
                )
                .accessibilityIdentifier("flows.routeAbout")

                ListRow(
                    "Route two pages deep",
                    subtitle: "A route may need several steps",
                    action: { route = .deepPage }
                )
                .accessibilityIdentifier("flows.routeDeep")
            }
        }
        .listLayoutStyle(.insetGrouped)
        .backButtonHidden()
        .navigationCheckpoint(KnownCheckpoints.flowsResult) { result in
            checkpointResult = result
        }
        .navigationOpen($openDestination)
        .navigationMove($moveDestination)
        .navigationMove(values: $moveValues)
        .navigationRoute($route)
    }
}

#Preview {
    FlowsCatalogScreen()
}
