//
// Copyright © 2025 Alexander Romanov
// Callback.swift, created on 23.08.2025
//

import SwiftUI

public struct Callback<Value>: Hashable, Equatable {
    public let identifier: String
    public let handler: (Value) -> Void

    public init(_ identifier: String = UUID().uuidString, handler: @escaping (Value) -> Void) {
        self.identifier = identifier
        self.handler = handler
    }

    public func callAsFunction(_ value: Value) {
        handler(value)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    public static func == (lhs: Callback<Value>, rhs: Callback<Value>) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
