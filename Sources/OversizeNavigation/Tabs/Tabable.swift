//
// Copyright © 2024 Alexander Romanov
// Tabable.swift, created on 14.04.2024
//

import SwiftUI

public protocol Tabable: Codable, CaseIterable, Identifiable {
    var icon: Image { get }
    var title: String { get }
}
