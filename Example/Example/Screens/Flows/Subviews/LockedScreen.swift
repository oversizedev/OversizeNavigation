//
// Copyright © 2026 Alexander Romanov
// LockedScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

/// While a screen is locked a global dismiss throws instead of tearing the stack down —
/// the pattern for a transaction that must not be interrupted.
struct LockedScreen: View {
    @State private var isDismissingAny: Bool = false
    @State private var isBackTriggered: Bool = false
    @State private var hud: OversizeNavigation.HUD?

    var body: some View {
        NavigationListLayout("Locked") {
            Section("Try to leave") {
                ListRow(
                    "Dismiss anything",
                    subtitle: "Fails while this screen is on the stack",
                    action: { isDismissingAny = true }
                )
                .accessibilityIdentifier("locked.dismissAny")

                ListRow(
                    "Pop this screen",
                    subtitle: "The lock only blocks the global dismiss",
                    action: { isBackTriggered = true }
                )
                .accessibilityIdentifier("locked.back")
            }
        }
        .listLayoutStyle(.insetGrouped)
        .navigationLocked()
        .navigationBack($isBackTriggered)
        .navigationDismissAny($isDismissingAny) { result in
            switch result {
            case .success:
                hud = .success("Dismissed")
            case let .failure(error):
                hud = .error(error)
            }
        }
        .presentationHUD($hud)
    }
}

#Preview {
    LockedScreen()
}
