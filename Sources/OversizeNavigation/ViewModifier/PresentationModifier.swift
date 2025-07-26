//
// Copyright © 2025 Alexander Romanov
// PresentationHUDModifier.swift, created on 19.07.2025
//

import OversizeCore
import OversizeUI
import SwiftUI

private struct PresentationModifier: ViewModifier {
    @State var hudState: HUDState = .init()

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .environment(\.hud, hudState)

            VStack(spacing: -40) {
                ForEach(hudState.displayedHUDs, id: \.id) { element in
                    let index = hudState.displayedHUDs.firstIndex(where: { $0.id == element.id }) ?? 0

                    HUDContent(
                        element.title,
                        icon: element.icon?.foregroundColor(element.color)
                    )
                    .padding(.horizontal, 8)
                    .scaleEffect(CGFloat(1.0 - (0.03 * Double(hudState.displayedHUDs.count - index - 1))))
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        )
                    )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: hudState.displayedHUDs.count)
            .animation(.easeInOut(duration: 0.3), value: hudState.displayedHUDs.map(\.id))
            .safeAreaPadding(.top, 5)
        }
    }
}

public extension View {
    func presentationRoot() -> some View {
        modifier(PresentationModifier())
    }
}

#Preview {
    struct Container: View {
        @Environment(\.hud) var hudState

        var body: some View {
            Color.surfacePrimary.ignoresSafeArea()
                .task {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    hudState.presentHUD(.success("Hello"))
                    try? await Task.sleep(nanoseconds: 800_000_000)
                    hudState.presentHUD(.destructive())
                    try? await Task.sleep(nanoseconds: 800_000_000)
                    hudState.presentHUD(.archive())
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    hudState.presentHUD(.favorite())
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    hudState.presentHUD(.unarchive())
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    hudState.presentHUD(.success("Long text that should be truncated in the HUD view"))
                    try? await Task.sleep(nanoseconds: 2_500_000_000)
                    hudState.presentHUD(.success("World"))
                    try? await Task.sleep(nanoseconds: 2_500_000_000)
                    hudState.presentHUD(.success("Final message"))
                }
        }
    }

    return Container().presentationRoot()
}
