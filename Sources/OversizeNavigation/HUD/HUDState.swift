import Foundation
import OversizeCore
import SwiftUI

@Observable
public class HUDState: @unchecked Sendable {
    public var hudStack: [HUD] = []
    private var dismissTasks: [String: Task<Void, Error>] = [:]

    private let maxDisplayedHUDs = 3

    public init() {}

    @MainActor
    public func presentHUD(_ hud: HUD) {
        hudStack.append(hud)
        Log.debug("💬 [HUD] Present \(hud.id)")
        dismissAfterDelay(for: hud)
    }

    public var displayedHUDs: [HUD] {
        Array(hudStack.suffix(maxDisplayedHUDs))
    }

    @MainActor
    public func clearAllHUDs() {
        dismissTasks.values.forEach { $0.cancel() }
        dismissTasks.removeAll()
        hudStack.removeAll()
    }

    @MainActor
    private func dismissAfterDelay(for hud: HUD) {
        let task = Task { @MainActor in
            try await Task.sleep(for: hud.duration ?? .seconds(2))
            try Task.checkCancellation()

            if let index = hudStack.firstIndex(where: { $0.id == hud.id }) {
                hudStack.remove(at: index)
                Log.debug("💬 [HUD] Dismiss \(hud.id)")
            }

            dismissTasks.removeValue(forKey: hud.id)
        }

        dismissTasks[hud.id] = task
    }
}

// MARK: - Environment Support

public extension EnvironmentValues {
    var hud: HUDState {
        get { self[HUDStateKey.self] }
        set { self[HUDStateKey.self] = newValue }
    }
}

private struct HUDStateKey: EnvironmentKey {
    static let defaultValue: HUDState = .init()
}
