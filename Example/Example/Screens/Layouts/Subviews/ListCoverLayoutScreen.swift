//
// Copyright © 2026 Alexander Romanov
// ListCoverLayoutScreen.swift, created on 05.09.2026
//

import OversizeNavigation
import OversizeUI
import SwiftUI

struct ListCoverLayoutScreen: View {
    var body: some View {
        NavigationListCoverLayout(
            "NavigationListCoverLayout",
            coverHeight: 220,
            content: {
                Section("Recently added") {
                    ForEach(1 ... 10, id: \.self) { item in
                        ListRow("Item \(item)")
                    }
                }

                Section("Favorites") {
                    ForEach(11 ... 30, id: \.self) { item in
                        ListRow("Item \(item)")
                    }
                }
            },
            cover: {
                Text("Cover header")
                    .headline()
                    .foregroundStyle(.white)
            },
            coverBackground: {
                LinearGradient(
                    colors: [.teal, .blue],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .listLayoutStyle(.insetGrouped)
        .coverSpacing(.zero)
    }
}

#Preview {
    ListCoverLayoutScreen()
}
