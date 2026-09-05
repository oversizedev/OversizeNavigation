//
// Copyright © 2026 Alexander Romanov
// ExampleLaunch.swift, created on 05.09.2026
//

import Foundation

enum ExampleLaunch {
    /// UI tests need a predictable cold start, so restored navigation state is skipped for them.
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-ExampleUITesting")
    }
}
