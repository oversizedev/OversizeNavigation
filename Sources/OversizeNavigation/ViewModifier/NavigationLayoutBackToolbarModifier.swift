//
// Copyright © 2026 Alexander Romanov
// NavigationLayoutBackToolbarModifier.swift, created on 30.08.2026
//

import NavigatorUI
import OversizeLocalizable
import OversizeUI
import SwiftUI

struct NavigationLayoutBackToolbarModifier: ViewModifier {
    @Environment(\.navigator) private var navigator

    let backConfirmation: BackConfirmationContent?
    let isBackButtonHidden: Bool?

    @State private var isBackConfirmationPresented: Bool = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                if isShowBackButton {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel, action: handleBackButtonTap) {
                            #if os(macOS)
                                // The Mac toolbar labels its controls; the glyph alone reads as
                                // decoration there. Which word it is follows the policy, so a pop
                                // is never labelled as a close.
                                Text(backButtonTitle)
                            #else
                                backImage.icon()
                            #endif
                        }
                        .accessibilityIdentifier(backButtonPolicy.backButtonRole.accessibilityIdentifier)
                        #if os(macOS)
                        .controlSize(.large)
                        #endif
                        .confirmationDialog(
                            backConfirmation?.title ?? "Are you sure?",
                            isPresented: $isBackConfirmationPresented,
                            titleVisibility: .visible,
                            presenting: backConfirmation,
                            actions: { details in
                                Button(
                                    details.confirmationButtonTitle,
                                    action: handleConfirmationBackTap
                                )
                                Button(
                                    details.cancelButtonTitle ?? "Cancel",
                                    role: .cancel,
                                    action: handleConfirmationCancelTap
                                )
                            },
                            message: { details in
                                Text(details.message)
                            }
                        )
                    }
                }
            }
            .interactiveDismissDisabled(isInteractiveBackDisabled)
            .navigationBarBackButtonHidden(isNavigationBarBackButtonHidden)
    }

    private func handleBackButtonTap() {
        if backConfirmation == nil {
            navigator.back()
        } else {
            isBackConfirmationPresented = true
        }
    }

    private func handleConfirmationBackTap() {
        isBackConfirmationPresented = false
        navigator.back()
    }

    private func handleConfirmationCancelTap() {
        isBackConfirmationPresented = false
    }

    private var backButtonPolicy: BackButtonPolicy {
        .init(
            isPresented: navigator.isPresented,
            count: navigator.count,
            isBackButtonHidden: isBackButtonHidden,
            hasBackConfirmation: backConfirmation != nil
        )
    }

    private var isInteractiveBackDisabled: Bool {
        backButtonPolicy.isInteractiveBackDisabled
    }

    private var isNavigationBarBackButtonHidden: Bool {
        backButtonPolicy.isNavigationBarBackButtonHidden
    }

    private var isShowBackButton: Bool {
        backButtonPolicy.isShowBackButton
    }

    private var backButtonTitle: String {
        switch backButtonPolicy.backButtonRole {
        case .close:
            L10n.Button.close
        case .pop:
            L10n.Button.back
        }
    }

    private var backImage: Image {
        switch backButtonPolicy.backButtonRole {
        case .close:
            if #available(macOS 26, iOS 26, tvOS 26, watchOS 26, *) {
                Image(systemName: "xmark")
            } else {
                Image.Base.close
            }
        case .pop:
            if #available(macOS 26, iOS 26, tvOS 26, watchOS 26, *) {
                Image(systemName: "chevron.left")
            } else {
                Image.Base.chevronLeft
            }
        }
    }
}

extension View {
    func navigationLayoutBackToolbar(
        backConfirmation: BackConfirmationContent?,
        isBackButtonHidden: Bool?
    ) -> some View {
        modifier(
            NavigationLayoutBackToolbarModifier(
                backConfirmation: backConfirmation,
                isBackButtonHidden: isBackButtonHidden
            )
        )
    }
}
