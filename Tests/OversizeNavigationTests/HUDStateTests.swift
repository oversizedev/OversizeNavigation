//
// Copyright © 2026 Alexander Romanov
// HUDStateTests.swift, created on 05.09.2026
//

@testable import OversizeNavigation
import Testing

@MainActor
struct HUDStateTests {
    @Test("A new state starts empty")
    func startsEmpty() {
        let state = HUDState()

        #expect(state.hudStack.isEmpty)
        #expect(state.displayedHUDs.isEmpty)
    }

    @Test("Presenting appends to the stack")
    func presentAppends() {
        let state = HUDState()

        state.presentHUD(.success("First"))
        state.presentHUD(.success("Second"))

        #expect(state.hudStack.count == 2)
        #expect(state.hudStack.first == .success("First"))
        #expect(state.hudStack.last == .success("Second"))
    }

    @Test("Only the three most recent HUDs are displayed")
    func displayIsCappedAtThree() {
        let state = HUDState()

        for index in 1 ... 5 {
            state.presentHUD(.default("HUD \(index)", duration: .seconds(30)))
        }

        #expect(state.hudStack.count == 5)
        #expect(state.displayedHUDs.count == 3)
        #expect(state.displayedHUDs.map(\.title) == ["HUD 3", "HUD 4", "HUD 5"])
    }

    @Test("Each presentation advances the feedback ticket")
    func feedbackTicketAdvances() {
        let state = HUDState()
        let initialTicket = state.sensoryFeedbackTicket

        state.presentHUD(.success())
        #expect(state.sensoryFeedbackTicket == initialTicket + 1)
        #expect(state.sensoryFeedback == .success)

        state.presentHUD(.error())
        #expect(state.sensoryFeedbackTicket == initialTicket + 2)
        #expect(state.sensoryFeedback == .error)
    }

    @Test("Clearing removes every HUD")
    func clearRemovesEverything() {
        let state = HUDState()

        state.presentHUD(.default("Kept", duration: .seconds(30)))
        state.presentHUD(.default("Also kept", duration: .seconds(30)))
        state.clearAllHUDs()

        #expect(state.hudStack.isEmpty)
        #expect(state.displayedHUDs.isEmpty)
    }

    @Test("A HUD dismisses itself once its duration elapses")
    func autoDismissAfterDuration() async throws {
        let state = HUDState()

        state.presentHUD(.default("Short", duration: .milliseconds(50)))
        state.presentHUD(.default("Long", duration: .seconds(30)))
        #expect(state.hudStack.count == 2)

        try await Task.sleep(for: .milliseconds(400))

        #expect(state.hudStack.map(\.title) == ["Long"])
    }

    @Test("Clearing cancels pending dismissals")
    func clearCancelsPendingDismissals() async throws {
        let state = HUDState()

        state.presentHUD(.default("Short", duration: .milliseconds(50)))
        state.clearAllHUDs()
        state.presentHUD(.default("Long", duration: .seconds(30)))

        try await Task.sleep(for: .milliseconds(400))

        #expect(state.hudStack.map(\.title) == ["Long"])
    }
}
