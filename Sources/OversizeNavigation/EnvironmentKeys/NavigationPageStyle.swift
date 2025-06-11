//
// Copyright © 2025 Alexander Romanov
// NavigationPageStyle.swift, created on 07.06.2025
//

import SwiftUI

public enum NavigationPageStyle: Sendable {
    case `default`, native
}

private struct IconStyleKey: EnvironmentKey {
    public static let defaultValue: NavigationPageStyle = .native
}

public extension EnvironmentValues {
    var navigationPageStyle: NavigationPageStyle {
        get { self[IconStyleKey.self] }
        set { self[IconStyleKey.self] = newValue }
    }
}

public extension View {
    func navigationPageStyle(_ navigationPageStyle: NavigationPageStyle = .default) -> some View {
        environment(\.navigationPageStyle, navigationPageStyle)
    }
}
