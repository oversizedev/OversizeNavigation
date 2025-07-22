//
// Copyright © 2025 Alexander Romanov
// HUDPresentable.swift, created on 19.07.2025
//

import Foundation

public protocol HUDPresentable: Equatable, Hashable, Identifiable {}

public extension HUDPresentable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
