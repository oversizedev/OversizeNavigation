//
// Copyright © 2026 Alexander Romanov
// ExampleApp.swift, created on 05.09.2026
//

import OversizeNavigation
import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .presentationHUDRoot()
                .navigationBarAppearanceConfiguration()
        }
    }
}
