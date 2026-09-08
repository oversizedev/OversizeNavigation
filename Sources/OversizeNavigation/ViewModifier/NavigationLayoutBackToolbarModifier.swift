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
        #if os(macOS)
            // The control lives in a header inside the pane, not in the window toolbar. A stack
            // whose path is bound to a navigator cannot sit in a NavigationSplitView detail
            // column on macOS — the column wipes the path on every programmatic push — so a Mac
            // window hosts its stacks beside a plain split pane, and a window toolbar has no way
            // to place an item over a pane (SwiftUI has no tracking separator). The header also
            // replaces the system back button, which would otherwise sit over the sidebar.
            content
                .safeAreaInset(edge: .top, spacing: 0) {
                    if isShowPaneHeader {
                        paneHeader
                    }
                }
                .interactiveDismissDisabled(isInteractiveBackDisabled)
                .navigationBarBackButtonHidden(isShowPaneHeader || isNavigationBarBackButtonHidden)
        #else
            content
                .toolbar {
                    if isShowBackButton {
                        ToolbarItem(placement: .cancellationAction) {
                            backButton
                        }
                    }
                }
                .interactiveDismissDisabled(isInteractiveBackDisabled)
                .navigationBarBackButtonHidden(isNavigationBarBackButtonHidden)
        #endif
    }

    #if os(macOS)
        /// Whether the pane draws its header. The policy decides for the controls this package
        /// owns; a plain pushed screen — where iOS keeps the system button — gets the header
        /// too, because the replaced system control has to be replaced with something.
        private var isShowPaneHeader: Bool {
            backButtonPolicy.isShowBackButton || navigator.count > 0
        }

        private var paneHeader: some View {
            HStack(spacing: 0) {
                Button(role: .cancel, action: handleBackButtonTap) {
                    // A labelled control, not a glyph: the header reads as text on a Mac, and
                    // which word it is follows the policy, so a pop is never labelled as a close.
                    Text(backButtonTitle)
                }
                .accessibilityIdentifier(backButtonPolicy.backButtonRole.accessibilityIdentifier)
                .modifier(BackConfirmationDialogModifier(
                    backConfirmation: backConfirmation,
                    isPresented: $isBackConfirmationPresented,
                    onConfirm: handleConfirmationBackTap,
                    onCancel: handleConfirmationCancelTap
                ))

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)
            .overlay(alignment: .bottom) {
                Divider()
            }
        }
    #else
        private var backButton: some View {
            Button(role: .cancel, action: handleBackButtonTap) {
                backImage.icon()
            }
            .accessibilityIdentifier(backButtonPolicy.backButtonRole.accessibilityIdentifier)
            .modifier(BackConfirmationDialogModifier(
                backConfirmation: backConfirmation,
                isPresented: $isBackConfirmationPresented,
                onConfirm: handleConfirmationBackTap,
                onCancel: handleConfirmationCancelTap
            ))
        }
    #endif

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

    #if os(macOS)
        private var backButtonTitle: String {
            switch backButtonPolicy.backButtonRole {
            case .close:
                L10n.Button.close
            case .pop:
                L10n.Button.back
            }
        }
    #else
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
    #endif
}

/// The confirmation both platforms attach to their back control, stated once so the header and
/// the toolbar item cannot drift apart.
private struct BackConfirmationDialogModifier: ViewModifier {
    let backConfirmation: BackConfirmationContent?
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                backConfirmation?.title ?? "Are you sure?",
                isPresented: $isPresented,
                titleVisibility: .visible,
                presenting: backConfirmation,
                actions: { details in
                    Button(
                        details.confirmationButtonTitle,
                        action: onConfirm
                    )
                    Button(
                        details.cancelButtonTitle ?? "Cancel",
                        role: .cancel,
                        action: onCancel
                    )
                },
                message: { details in
                    Text(details.message)
                }
            )
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
