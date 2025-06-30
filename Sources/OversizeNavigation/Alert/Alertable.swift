//
// Copyright © 2024 Alexander Romanov
// Alertable.swift, created on 14.04.2024
//

import Foundation

public protocol Alertable: Equatable, Hashable, Identifiable {}

public extension Alertable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
