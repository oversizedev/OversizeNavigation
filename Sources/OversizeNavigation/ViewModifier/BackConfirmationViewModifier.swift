//
// Copyright © 2026 Alexander Romanov
// BackConfirmationViewModifier.swift, created on 02.06.2026
//

import SwiftUI

private struct BackConfirmationViewModifier: ViewModifier {
    let confirmationContent: BackConfirmationContent

    @Environment(\.dismiss) private var dismiss
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .interactiveDismissDisabled()
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(confirmationContent.cancelButtonTitle ?? "Close", systemImage: "xmark", role: .cancel) {
                        isPresented = true
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                    .confirmationDialog(
                        confirmationContent.title,
                        isPresented: $isPresented,
                        titleVisibility: .visible
                    ) {
                        Button(confirmationContent.confirmationButtonTitle, role: .destructive) {
                            dismiss()
                        }
                        Button(confirmationContent.cancelButtonTitle ?? "Cancel", role: .cancel) {}
                    } message: {
                        if !confirmationContent.message.isEmpty {
                            Text(confirmationContent.message)
                        }
                    }
                    #if !os(tvOS) && !os(watchOS)
                    .keyboardShortcut(.cancelAction)
                    #endif
                }
            }
    }
}

public extension View {
    func backConfirmationDialog(_ content: BackConfirmationContent?) -> some View {
        Group {
            if let content {
                modifier(BackConfirmationViewModifier(confirmationContent: content))
            } else {
                self
            }
        }
    }
}
