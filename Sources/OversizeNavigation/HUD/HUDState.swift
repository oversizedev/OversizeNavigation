import Foundation
import OversizeCore
import SwiftUI

@Observable
public class HUDState: @unchecked Sendable {
    struct PresentedHUD: Identifiable {
        let id: UUID
        let hud: HUD
    }

    private var presentedStack: [PresentedHUD] = []
    private var dismissTasks: [UUID: Task<Void, Error>] = [:]

    public private(set) var sensoryFeedback: SensoryFeedback = .selection
    public private(set) var sensoryFeedbackTicket: Int = 0

    private let maxDisplayedHUDs = 3

    public init() {}

    public var hudStack: [HUD] {
        presentedStack.map(\.hud)
    }

    public var displayedHUDs: [HUD] {
        Array(hudStack.suffix(maxDisplayedHUDs))
    }

    var displayedPresentedHUDs: [PresentedHUD] {
        Array(presentedStack.suffix(maxDisplayedHUDs))
    }

    @MainActor
    public func presentHUD(_ hud: HUD) {
        let presented = PresentedHUD(id: UUID(), hud: hud)
        presentedStack.append(presented)
        sensoryFeedback = hud.sensoryFeedback
        sensoryFeedbackTicket &+= 1
        Log.debug("💬 [HUD] Present \(hud.id)")
        dismissAfterDelay(for: presented)
    }

    @MainActor
    public func clearAllHUDs() {
        dismissTasks.values.forEach { $0.cancel() }
        dismissTasks.removeAll()
        presentedStack.removeAll()
    }

    @MainActor
    private func dismissAfterDelay(for presented: PresentedHUD) {
        let task = Task { @MainActor in
            try await Task.sleep(for: presented.hud.duration ?? .seconds(2))
            try Task.checkCancellation()

            if let index = presentedStack.firstIndex(where: { $0.id == presented.id }) {
                presentedStack.remove(at: index)
                Log.debug("💬 [HUD] Dismiss \(presented.hud.id)")
            }

            dismissTasks.removeValue(forKey: presented.id)
        }

        dismissTasks[presented.id] = task
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
