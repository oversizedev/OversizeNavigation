//
// Copyright © 2025 Alexander Romanov
// NavigationBarAppearenceColor.swift, created on 05.06.2025
//

import OversizeUI
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

public struct NavigationBarAppearence: ViewModifier {
    public init() {
        #if os(iOS)
            guard let backImage = UIImage(named: "ArrowLeft", in: .module, with: nil) else { return }
            let tintColor = UIColor(Color.onSurfacePrimary)
            let preparedImage = backImage.withTintColor(tintColor, renderingMode: .alwaysOriginal)

            let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
            backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: tintColor]
            backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: tintColor]
            backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: tintColor]
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: tintColor]

            let appearanceDefault = UINavigationBarAppearance()
            appearanceDefault.configureWithOpaqueBackground()
            appearanceDefault.setBackIndicatorImage(preparedImage, transitionMaskImage: preparedImage)
            appearanceDefault.backButtonAppearance = backButtonAppearance
            appearanceDefault.titleTextAttributes = [.foregroundColor: tintColor]
            appearanceDefault.largeTitleTextAttributes = [.foregroundColor: tintColor]

            let appearanceTransparent = UINavigationBarAppearance()
            appearanceTransparent.configureWithTransparentBackground()
            appearanceTransparent.setBackIndicatorImage(preparedImage, transitionMaskImage: preparedImage)
            appearanceTransparent.backButtonAppearance = backButtonAppearance
            appearanceTransparent.titleTextAttributes = [.foregroundColor: tintColor]
            appearanceTransparent.largeTitleTextAttributes = [.foregroundColor: tintColor]

            UINavigationBar.appearance().standardAppearance = appearanceDefault
            UINavigationBar.appearance().scrollEdgeAppearance = appearanceTransparent
            UINavigationBar.appearance().compactAppearance = appearanceDefault

            UINavigationBar.appearance().backIndicatorImage = preparedImage
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = preparedImage

            UINavigationBar.appearance().layoutMargins.left = 20
            UINavigationBar.appearance().layoutMargins.right = 20
        #endif
    }

    public func body(content: Content) -> some View {
        content
    }
}

public extension View {
    func naviagtionBarAppearenceConfiguration() -> some View {
        modifier(
            NavigationBarAppearence()
        )
    }
}
