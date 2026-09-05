//
// Copyright © 2026 Alexander Romanov
// AboutScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct AboutScreen: View {
    var body: some View {
        NavigationLayout("About") {
            Section("OversizeNavigation") {
                Row("Layouts", subtitle: "NavigationLayout, list, cover and list cover")
                Row("Navigator", subtitle: "Push, present, send, routes and checkpoints")
                Row("Feedback", subtitle: "HUD stack and AppAlert")
            }
        }
        .sectionTitlePosition(.inside)
        .bordered()
    }
}

#Preview {
    AboutScreen()
}
