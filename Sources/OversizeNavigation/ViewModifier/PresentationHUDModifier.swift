//
// Copyright © 2025 Alexander Romanov
// PresentationHUDModifier.swift, created on 19.07.2025
//

import OversizeCore
import OversizeUI
import SwiftUI

private struct PresentationHUDModifier: ViewModifier {
    @Binding var hud: HUD?
    @Environment(\.hud) var hudState: HUDState

    func body(content: Content) -> some View {
        content
            .onChange(of: hud) { _, newValue in
                if let newValue {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hudState.presentHUD(newValue)
                    }
                    self.hud = nil
                }
            }
    }
}

public extension View {
    func presentationHUD(_ hud: Binding<HUD?>) -> some View {
        modifier(PresentationHUDModifier(hud: hud))
    }
}
