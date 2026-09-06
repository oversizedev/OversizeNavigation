//
// Copyright © 2026 Alexander Romanov
// LoadingStateScreen.swift, created on 05.09.2026
//

import OversizeCore
import OversizeNavigation
import OversizeUI
import SwiftUI

struct LoadingStateScreen: View {
    /// `contentUnavailable` needs a result that can report emptiness, so the demo wraps its items.
    private struct DemoItems: Emptyable {
        let values: [String]

        var isEmpty: Bool {
            values.isEmpty
        }
    }

    private struct DemoError: LocalizedError {
        var errorDescription: String? {
            "Could not load the items"
        }

        var recoverySuggestion: String? {
            "Pick another state above"
        }
    }

    private enum DemoState: String, CaseIterable, Identifiable {
        case loading
        case empty
        case result
        case error

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .loading: "Loading"
            case .empty: "Empty"
            case .result: "Result"
            case .error: "Error"
            }
        }
    }

    private enum DemoOverlay: String, CaseIterable, Identifiable {
        case contentUnavailable
        case errorState

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .contentUnavailable: "Unavailable"
            case .errorState: "Error only"
            }
        }
    }

    @State private var demoState: DemoState = .empty
    @State private var demoOverlay: DemoOverlay = .contentUnavailable

    /// The overlays cover everything they are applied to, so they wrap the items alone — over the
    /// whole screen they would also hide the pickers that pick the state being demonstrated.
    var body: some View {
        NavigationListLayout("Loading states") {
            Section("State") {
                Picker("State", selection: $demoState) {
                    ForEach(DemoState.allCases) { state in
                        Text(state.title).tag(state)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("loadingState.picker")
            }

            Section("Overlay") {
                Picker("Overlay", selection: $demoOverlay) {
                    ForEach(DemoOverlay.allCases) { overlay in
                        Text(overlay.title).tag(overlay)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("loadingState.overlay")
            }

            Section("Content") {
                overlaidItems
                    .frame(maxWidth: .infinity, minHeight: 240)
            }
        }
        .listLayoutStyle(.insetGrouped)
    }

    @ViewBuilder
    private var overlaidItems: some View {
        switch demoOverlay {
        case .contentUnavailable:
            items.contentUnavailable(
                state,
                title: "Nothing here yet",
                subtitle: "Switch the picker to see the other states"
            ) {
                EmptyView()
            }
        case .errorState:
            items.errorState(state)
        }
    }

    @ViewBuilder
    private var items: some View {
        if case let .result(items) = state, items.isEmpty == false {
            VStack(spacing: .zero) {
                ForEach(items.values, id: \.self) { item in
                    ListRow(item)
                }
            }
        } else {
            Color.clear
        }
    }

    private var state: LoadingState<DemoItems> {
        switch demoState {
        case .loading:
            .loading
        case .empty:
            .result(DemoItems(values: []))
        case .result:
            .result(DemoItems(values: (1 ... 10).map { "Item \($0)" }))
        case .error:
            .error(DemoError())
        }
    }
}

#Preview {
    LoadingStateScreen()
}
