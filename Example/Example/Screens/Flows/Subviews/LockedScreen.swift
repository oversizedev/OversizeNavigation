//
// Copyright © 2026 Alexander Romanov
// LockedScreen.swift, created on 05.09.2026
//

import NavigatorUI
import OversizeNavigation
import OversizeUI
import SwiftUI

/// While a screen is locked a global `dismissAny()` throws instead of tearing the stack down —
/// the pattern for a transaction that must not be interrupted.
struct LockedScreen: View {
    @Environment(\.navigator) private var navigator

    @State private var hud: OversizeNavigation.HUD?

    var body: some View {
        NavigationListLayout("Locked") {
            Section("Try to leave") {
                ListRow(
                    "Dismiss anything",
                    subtitle: "Throws while this screen is on the stack",
                    action: { dismissAny() }
                )
                .accessibilityIdentifier("locked.dismissAny")

                ListRow(
                    "Pop this screen",
                    subtitle: "The lock only blocks the global dismiss",
                    action: { _ = navigator.back() }
                )
                .accessibilityIdentifier("locked.back")
            }
        }
        .listLayoutStyle(.insetGrouped)
        .navigationLocked()
        .presentationHUD($hud)
    }

    private func dismissAny() {
        do {
            _ = try navigator.dismissAny()
            hud = .success("Dismissed")
        } catch {
            hud = .error(error)
        }
    }
}

#Preview {
    LockedScreen()
}
