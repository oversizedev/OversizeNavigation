//
// Copyright © 2026 Alexander Romanov
// SelectableListLayoutScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct SelectableListLayoutScreen: View {
    @State private var selection: Set<Int>? = []

    var body: some View {
        NavigationListLayout("Selection", selection: $selection) {
            Section("Selected: \(selection?.count ?? 0)") {
                ForEach(1 ... 20, id: \.self) { item in
                    ListRow("Item \(item)")
                        .tag(item)
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        #if !os(macOS)
            // A Mac list selects on click and has no editing mode to enter, so `EditButton` is
            // unavailable there rather than merely unnecessary.
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                        .accessibilityIdentifier("selection.edit")
                }
            }
        #endif
    }
}

#Preview {
    SelectableListLayoutScreen()
}
