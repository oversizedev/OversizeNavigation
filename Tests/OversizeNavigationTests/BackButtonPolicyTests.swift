//
// Copyright © 2026 Alexander Romanov
// BackButtonPolicyTests.swift, created on 05.09.2026
//

@testable import OversizeNavigation
import Testing

struct BackButtonPolicyTests {
    // MARK: - Presentation root

    @Test("Root of a presentation shows a closing control")
    func presentationRootShowsControl() {
        let policy = BackButtonPolicy(
            isPresented: true,
            count: 0,
            isBackButtonHidden: nil,
            hasBackConfirmation: false
        )

        #expect(policy.isPresentationRoot)
        #expect(policy.isShowBackButton)
        #expect(policy.isNavigationBarBackButtonHidden == false)
        #expect(policy.isInteractiveBackDisabled == false)
    }

    @Test("A pushed screen inside a presentation is not a presentation root")
    func pushedScreenInsidePresentation() {
        let policy = BackButtonPolicy(
            isPresented: true,
            count: 1,
            isBackButtonHidden: nil,
            hasBackConfirmation: false
        )

        #expect(policy.isPresentationRoot == false)
        #expect(policy.isShowBackButton == false)
    }

    @Test("A pushed screen keeps the system back button")
    func pushedScreenKeepsSystemBackButton() {
        let policy = BackButtonPolicy(
            isPresented: false,
            count: 2,
            isBackButtonHidden: nil,
            hasBackConfirmation: false
        )

        #expect(policy.isShowBackButton == false)
        #expect(policy.isNavigationBarBackButtonHidden == false)
    }

    // MARK: - Back confirmation

    @Test(
        "A confirmation replaces the system back button on every screen",
        arguments: [
            (isPresented: false, count: 0),
            (isPresented: false, count: 3),
            (isPresented: true, count: 0),
            (isPresented: true, count: 3),
        ]
    )
    func confirmationReplacesSystemBackButton(state: (isPresented: Bool, count: Int)) {
        let policy = BackButtonPolicy(
            isPresented: state.isPresented,
            count: state.count,
            isBackButtonHidden: nil,
            hasBackConfirmation: true
        )

        #expect(policy.isShowBackButton)
        #expect(policy.isNavigationBarBackButtonHidden)
        #expect(policy.isInteractiveBackDisabled)
    }

    @Test("Without a confirmation the interactive dismiss stays enabled")
    func interactiveDismissEnabledWithoutConfirmation() {
        let policy = BackButtonPolicy(
            isPresented: true,
            count: 0,
            isBackButtonHidden: nil,
            hasBackConfirmation: false
        )

        #expect(policy.isInteractiveBackDisabled == false)
    }

    // MARK: - backButtonHidden

    @Test("backButtonHidden hides the control while the stack is at its root")
    func backButtonHiddenAtRoot() {
        let policy = BackButtonPolicy(
            isPresented: true,
            count: 0,
            isBackButtonHidden: true,
            hasBackConfirmation: false
        )

        #expect(policy.isBackButtonAtRootHidden)
        #expect(policy.isShowBackButton == false)
        #expect(policy.isNavigationBarBackButtonHidden)
    }

    @Test("backButtonHidden does not affect pushed screens")
    func backButtonHiddenIgnoredWhenPushed() {
        let policy = BackButtonPolicy(
            isPresented: true,
            count: 1,
            isBackButtonHidden: true,
            hasBackConfirmation: false
        )

        #expect(policy.isBackButtonAtRootHidden == false)
        #expect(policy.isNavigationBarBackButtonHidden == false)
    }

    @Test("backButtonHidden wins over a confirmation at the root")
    func backButtonHiddenWinsOverConfirmation() {
        let policy = BackButtonPolicy(
            isPresented: true,
            count: 0,
            isBackButtonHidden: true,
            hasBackConfirmation: true
        )

        #expect(policy.isShowBackButton == false)
        #expect(policy.isNavigationBarBackButtonHidden)
        #expect(policy.isInteractiveBackDisabled)
    }

    @Test("backButtonHidden set to false behaves like an unset value")
    func explicitFalseBehavesLikeUnset() {
        let explicit = BackButtonPolicy(
            isPresented: true,
            count: 0,
            isBackButtonHidden: false,
            hasBackConfirmation: false
        )
        let unset = BackButtonPolicy(
            isPresented: true,
            count: 0,
            isBackButtonHidden: nil,
            hasBackConfirmation: false
        )

        #expect(explicit.isShowBackButton == unset.isShowBackButton)
        #expect(explicit.isBackButtonAtRootHidden == unset.isBackButtonAtRootHidden)
    }

    // MARK: - Full matrix

    @Test(
        "The control appears only for a presentation root or a confirmation",
        arguments: [false, true],
        [0, 1, 2]
    )
    func controlVisibilityMatrix(isPresented: Bool, count: Int) {
        for isBackButtonHidden in [nil, true, false] as [Bool?] {
            for hasBackConfirmation in [false, true] {
                let policy = BackButtonPolicy(
                    isPresented: isPresented,
                    count: count,
                    isBackButtonHidden: isBackButtonHidden,
                    hasBackConfirmation: hasBackConfirmation
                )

                let hiddenAtRoot = isBackButtonHidden == true && count == 0
                let expected = hiddenAtRoot
                    ? false
                    : (isPresented && count == 0) || hasBackConfirmation

                #expect(policy.isShowBackButton == expected)
            }
        }
    }
}
