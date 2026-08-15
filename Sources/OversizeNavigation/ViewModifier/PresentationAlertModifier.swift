//
// Copyright © 2025 Alexander Romanov
// PresentationAlertModifier.swift, created on 19.07.2025
//

import OversizeCore
import SwiftUI

private struct PresentationAlertModifier: ViewModifier {
    @Binding private var alert: AppAlert?
    @State private var sensoryFeedback: SensoryFeedback = .error
    @State private var sensoryFeedbackTicket: Int = 0

    init(alert: Binding<AppAlert?>) {
        _alert = alert
    }

    func body(content: Content) -> some View {
        content
            .alert(item: $alert) { $0.alert }
            .onChange(of: alert, initial: true) { _, alert in
                guard let alert else { return }
                #if DEBUG
                    Log.debug("🔔 [ALERT] Presented \(alert.id)")
                #endif
                if let feedback = alert.sensoryFeedback {
                    sensoryFeedback = feedback
                    sensoryFeedbackTicket &+= 1
                }
            }
            .sensoryFeedback(sensoryFeedback, trigger: sensoryFeedbackTicket)
    }
}

public extension View {
    func presentationAlert(_ alert: Binding<AppAlert?>) -> some View {
        modifier(PresentationAlertModifier(alert: alert))
    }
}
