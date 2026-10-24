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
                    ToolbarItem(placement: backButtonPlacement) {
                        backButton
                    }
                }
            }
            .interactiveDismissDisabled(isInteractiveBackDisabled)
            .navigationBarBackButtonHidden(isNavigationBarBackButtonHidden)
    }


    private var backButtonPlacement: ToolbarItemPlacement {
        #if os(macOS)
            isBackButtonInBottomBar ? .cancellationAction : .navigation
        #else
            .cancellationAction
        #endif
    }

    private var isBackButtonInBottomBar: Bool {
        backButtonPolicy.backButtonRole == .close || backButtonPolicy.isPresented
    }

    private var backButton: some View {
        Button(role: .cancel, action: handleBackButtonTap) {
            backButtonLabel
        }
        .accessibilityIdentifier(backButtonPolicy.backButtonRole.accessibilityIdentifier)
        .accessibilityLabel(backButtonTitle)
        .help(backButtonTitle)
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
            navigator: navigator,
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

    @ViewBuilder
    private var backButtonLabel: some View {
        #if os(macOS)
            if isBackButtonInBottomBar {
                Text(backButtonTitle)
            } else {
                Image(systemName: "chevron.backward")
            }
        #else
            backImage.icon()
        #endif
    }

    private var backButtonTitle: String {
        switch backButtonPolicy.backButtonRole {
        case .close:
            #if os(macOS)
                L10n.Button.cancel
            #else
                L10n.Button.close
            #endif
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
