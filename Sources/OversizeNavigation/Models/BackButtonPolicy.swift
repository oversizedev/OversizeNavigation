//
// Copyright © 2026 Alexander Romanov
// BackButtonPolicy.swift, created on 05.09.2026
//

/// Decides how the back control of a navigation layout behaves for a given navigator state.
///
/// The layouts and the shared back toolbar modifier all need the same answers, and the rules
/// depend only on plain values, so they live here instead of being repeated inside each view.
struct BackButtonPolicy: Equatable, Sendable {
    /// Whether the navigator owning the screen is itself presented (sheet, cover, split detail).
    let isPresented: Bool

    /// How many screens the navigator has pushed on top of its root.
    let count: Int

    /// Value set by `backButtonHidden(_:)`, or `nil` when the modifier was never applied.
    let isBackButtonHidden: Bool?

    /// Whether `backConfirmationDialog(_:)` supplied a confirmation.
    let hasBackConfirmation: Bool

    /// The screen roots a presentation, so the control closes it instead of popping.
    var isPresentationRoot: Bool {
        isPresented && count == 0
    }

    /// What the control does when tapped. The glyph, the macOS label and the accessibility
    /// identifier all read this rather than re-deriving the rule, so a layout cannot end up
    /// labelling a pop as a close — which is what macOS did while its branch ignored the policy.
    var backButtonRole: BackButtonRole {
        isPresentationRoot ? .close : .pop
    }

    /// `backButtonHidden(_:)` only applies while the stack sits at its root — pushed screens
    /// keep their back button.
    var isBackButtonAtRootHidden: Bool {
        isBackButtonHidden == true && count == 0
    }

    var isInteractiveBackDisabled: Bool {
        hasBackConfirmation
    }

    var isNavigationBarBackButtonHidden: Bool {
        hasBackConfirmation || isBackButtonAtRootHidden
    }

    /// A custom control is needed either to close a presentation from its root, or to route the
    /// system back gesture through the confirmation dialog.
    var isShowBackButton: Bool {
        if isBackButtonAtRootHidden {
            return false
        }
        return isPresentationRoot || hasBackConfirmation
    }
}

/// Whether the back control leaves a presentation or moves back within a stack.
enum BackButtonRole: String, Equatable, Sendable, CaseIterable {
    /// The control closes the presentation the screen roots.
    case close

    /// The control returns to the previous screen on the same stack.
    case pop

    /// Identifier the UI tests address the control by, on every platform.
    var accessibilityIdentifier: String {
        "navigationBack.\(rawValue)"
    }
}
