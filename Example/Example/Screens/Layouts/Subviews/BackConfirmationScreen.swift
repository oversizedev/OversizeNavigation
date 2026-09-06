//
// Copyright © 2026 Alexander Romanov
// BackConfirmationScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

/// A confirmation replaces the system back button and blocks the interactive dismiss, so the
/// same screen behaves the same whether it was pushed or presented.
struct BackConfirmationScreen: View {
    let isSheet: Bool

    @State private var draft: String = "Unsaved draft"

    var body: some View {
        NavigationLayout(isSheet ? "Sheet with confirmation" : "Pushed with confirmation") {
            Section("Draft") {
                TextField("Draft", text: $draft)
                    .textFieldStyle(.default)
                    .accessibilityIdentifier("backConfirmation.draft")
            }

            Section("What to expect") {
                Row(
                    isSheet ? "Close asks first" : "Back asks first",
                    subtitle: "The swipe to dismiss is disabled while a confirmation is set"
                )
            }
        }
        .backConfirmationDialog(.discard)
        .sectionTitlePosition(.inside)
        // As a sheet on macOS this screen has no title bar, so it names itself for the UI tests.
        .accessibilityIdentifier(isSheet ? "screen.Sheet with confirmation" : "screen.Pushed with confirmation")
    }
}

#Preview {
    BackConfirmationScreen(isSheet: false)
}
