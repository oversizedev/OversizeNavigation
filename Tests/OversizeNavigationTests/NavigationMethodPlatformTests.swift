//
// Copyright © 2026 Alexander Romanov
// NavigationMethodPlatformTests.swift, created on 06.09.2026
//

import NavigatorUI
@testable import OversizeNavigation
import Testing

/// NavigatorUI renders `.fullScreenCover` only where the platform has one, so a destination
/// asking for a cover on macOS presents nothing at all. The substitution is a plain value, and
/// it is pinned here rather than left to be rediscovered from an empty screen.
struct NavigationMethodPlatformTests {
    /// The condition mirrors NavigatorUI's own — naming macOS alone would leave visionOS, which
    /// the package supports and which has no cover either, presenting nothing.
    @Test("A cover falls back to a sheet only where the platform has no cover")
    func managedCoverFallback() {
        #if os(iOS) || os(tvOS) || os(watchOS)
            #expect(NavigationMethod.platformManagedCover == .managedCover)
            #expect(NavigationMethod.platformCover == .cover)
        #else
            #expect(NavigationMethod.platformManagedCover == .managedSheet)
            #expect(NavigationMethod.platformCover == .sheet)
        #endif
    }

    /// The managed variant is what carries its own navigation stack, so a presented screen can
    /// still push. Substituting it for the unmanaged one would take that away silently.
    @Test("The managed and unmanaged variants stay distinct after the substitution")
    func managedVariantStaysManaged() {
        #expect(NavigationMethod.platformManagedCover != NavigationMethod.platformCover)

        let managed: Set<NavigationMethod> = [.managedSheet, .managedCover]
        #expect(managed.contains(NavigationMethod.platformManagedCover))
        #expect(managed.contains(NavigationMethod.platformCover) == false)
    }
}
