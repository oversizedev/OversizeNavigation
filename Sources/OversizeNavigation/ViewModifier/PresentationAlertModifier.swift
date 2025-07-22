//
// Copyright © 2025 Alexander Romanov
// PresentationAlertModifier.swift, created on 19.07.2025
//

import OversizeCore
import SwiftUI

private struct PresentationAlertModifier: ViewModifier {
    @Binding private var alert: AppAlert?

    init(alert: Binding<AppAlert?>) {
        _alert = alert
    }

    func body(content: Content) -> some View {
        content
            .alert(item: $alert) { $0.alert }
        #if DEBUG
            .onChange(of: alert) { _, alert in
                if let alert {
                    logUI("Alert present \(alert.id)")
                }
            }
        #endif
    }
}

public extension View {
    func presentationAlert(_ alert: Binding<AppAlert?>) -> some View {
        modifier(PresentationAlertModifier(alert: alert))
    }
}
