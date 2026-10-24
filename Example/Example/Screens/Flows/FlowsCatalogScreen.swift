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
        NavigationLayout("Flows") {
            Section("Push") {
                Row(
                    "navigationOpen",
                    subtitle: "Local and deterministic, stays on this stack",
                    action: { openDestination = .page(1) }
                )
                .accessibilityIdentifier("flows.open")

                Row(
                    "navigationMove",
                    subtitle: "Broadcast, resolved by the receiving stack",
                    action: { moveDestination = .page(1) }
                )
                .accessibilityIdentifier("flows.move")
            }

            Section("Presentation") {
                Row(
                    "Managed sheet",
                    subtitle: "Destination declares .managedSheet",
                    action: { openDestination = .sheet }
                )
                .accessibilityIdentifier("flows.sheet")

                Row(
                    "Managed cover",
                    subtitle: "Destination declares .platformManagedCover",
                    action: { openDestination = .cover }
                )
                .accessibilityIdentifier("flows.cover")

                Row(
                    "Locked screen",
                    subtitle: "navigationLocked blocks the allPresentations exit",
                    action: { openDestination = .locked }
                )
                .accessibilityIdentifier("flows.locked")
            }

            Section("Checkpoints") {
                Row(
                    "Return a value",
                    subtitle: checkpointResult.map { "Last result: \($0)" } ?? "No result yet",
                    action: { openDestination = .checkpointResult }
                )
                .accessibilityIdentifier("flows.checkpointResult")
            }

            Section("Deep links") {
                Row(
                    "Send to the HUD screen",
                    subtitle: "navigationMove(values:) switches tab, then pushes",
                    action: { moveValues = ExampleRoutes.hud.moveValues }
                )
                .accessibilityIdentifier("flows.sendHUD")

                Row(
                    "Route to About",
                    subtitle: "One router for URLs and buttons",
                    action: { route = .about }
                )
                .accessibilityIdentifier("flows.routeAbout")

                Row(
                    "Route two pages deep",
                    subtitle: "A route may need several steps",
                    action: { route = .deepPage }
                )
                .accessibilityIdentifier("flows.routeDeep")
            }
        } background: {
            Color.backgroundSecondary
        }
        .listLayoutStyle(.insetGrouped)
        .sectionBordered()
        .sectionTitlePosition(.inside)
        .sectionTitleSeparator(.visible)
        .navigationCheckpoint(KnownCheckpoints.flowsResult) { result in
            checkpointResult = result
        }
        .navigationOpen($openDestination)
        .navigationMove($moveDestination)
        .navigationMove(values: $moveValues)
        .navigationRoute($route)
        .accessibilityIdentifier("screen.Flows")
    }
}

#Preview {
    FlowsCatalogScreen()
}
