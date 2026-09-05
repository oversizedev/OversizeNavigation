//
// Copyright © 2026 Alexander Romanov
// CheckpointResultScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

/// A value-returning checkpoint replaces the usual chain of bindings: this screen names the
/// place it wants to return to and hands it a value.
struct CheckpointResultScreen: View {
    @State private var value: Int = 42
    @State private var returnedValue: Int?

    var body: some View {
        NavigationListLayout("Return a value") {
            Section("Value") {
                Stepper("Value: \(value)", value: $value, in: 0 ... 100)
                    .accessibilityIdentifier("checkpoint.stepper")
            }

            Section("Return") {
                ListRow(
                    "Return \(value) to the flows root",
                    action: { returnedValue = value }
                )
                .accessibilityIdentifier("checkpoint.return")
            }
        }
        .listLayoutStyle(.insetGrouped)
        .navigationReturn(to: KnownCheckpoints.flowsResult, value: $returnedValue)
    }
}

#Preview {
    CheckpointResultScreen()
}
