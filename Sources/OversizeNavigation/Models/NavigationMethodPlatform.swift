//
// Copyright © 2026 Alexander Romanov
// NavigationMethodPlatform.swift, created on 06.09.2026
//

import NavigatorUI

public extension NavigationMethod {
    /// A full screen cover where the platform has one, a managed sheet where it does not.
    ///
    /// NavigatorUI renders `.fullScreenCover` only on iOS, tvOS and watchOS — its presentation
    /// modifiers wrap the cover in `#if os(iOS) || os(tvOS) || os(watchOS)`. A destination that
    /// asks for `.managedCover` anywhere else therefore sets state nothing renders, and the
    /// screen silently never appears. Naming the intent once here keeps that from being
    /// rediscovered at every call site.
    ///
    /// The condition mirrors NavigatorUI's own rather than naming macOS, so visionOS — which
    /// also has no cover there — is covered too, and a platform NavigatorUI adds later needs no
    /// change here.
    static var platformManagedCover: NavigationMethod {
        #if os(iOS) || os(tvOS) || os(watchOS)
            .managedCover
        #else
            .managedSheet
        #endif
    }

    /// The same fallback for the unmanaged cover, which NavigatorUI gates identically.
    static var platformCover: NavigationMethod {
        #if os(iOS) || os(tvOS) || os(watchOS)
            .cover
        #else
            .sheet
        #endif
    }
}
