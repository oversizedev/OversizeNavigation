//
// Copyright © 2026 Alexander Romanov
// HUDTests.swift, created on 05.09.2026
//

import Foundation
import OversizeUI
import SwiftUI
import Testing
@testable import OversizeNavigation

@MainActor
struct HUDTests {
    // MARK: - Titles

    @Test("Every case falls back to its default title")
    func defaultTitles() {
        #expect(HUD.success().title == "Success")
        #expect(HUD.destructive().title == "Error")
        #expect(HUD.delete().title == "Deleted")
        #expect(HUD.archive().title == "Archived")
        #expect(HUD.unarchive().title == "Unarchived")
        #expect(HUD.favorite().title == "Added to favorites")
        #expect(HUD.unfavorite().title == "Removed from favorites")
    }

    @Test("A supplied text replaces the default title")
    func customTitle() {
        #expect(HUD.success("Saved").title == "Saved")
        #expect(HUD.default("Copied").title == "Copied")
    }

    @Test("An error case uses the localized description")
    func errorTitle() {
        struct SampleError: LocalizedError {
            var errorDescription: String? { "Sample failed" }
        }

        #expect(HUD.error(SampleError()).title == "Sample failed")
        #expect(HUD.error().title == "An error occurred")
    }

    // MARK: - Duration

    @Test("The default case keeps its custom duration")
    func customDuration() {
        #expect(HUD.default("Copied", duration: .seconds(1)).duration == Duration.seconds(1))
        #expect(HUD.default("Copied").duration == Duration.seconds(4))
    }

    @Test("Other cases share the same duration")
    func sharedDuration() {
        #expect(HUD.success().duration == Duration.seconds(4))
        #expect(HUD.delete().duration == Duration.seconds(4))
    }

    // MARK: - Appearance

    @Test("Destructive cases are tinted with the error color")
    func destructiveColor() {
        #expect(HUD.destructive().color == Color.error)
        #expect(HUD.delete().color == Color.error)
        #expect(HUD.error().color == Color.error)
    }

    @Test("The plain case carries no icon")
    func plainCaseHasNoIcon() {
        #expect(HUD.default("Copied").icon == nil)
        #expect(HUD.success().icon != nil)
    }

    // MARK: - Feedback

    @Test("Feedback matches the meaning of the case")
    func sensoryFeedback() {
        #expect(HUD.success().sensoryFeedback == .success)
        #expect(HUD.error().sensoryFeedback == .error)
        #expect(HUD.delete().sensoryFeedback == .error)
        #expect(HUD.archive().sensoryFeedback == .warning)
        #expect(HUD.default("Copied").sensoryFeedback == .selection)
    }

    // MARK: - Identity

    @Test("The static shorthand equals the parameterless case")
    func staticShorthand() {
        #expect(HUD.success == HUD.success())
        #expect(HUD.delete == HUD.delete())
        #expect(HUD.favorite == HUD.favorite())
    }

    @Test("Equality and hashing follow the identifier")
    func identityDrivesEquality() {
        #expect(HUD.success("Saved") == HUD.success("Saved"))
        #expect(HUD.success("Saved") != HUD.success("Stored"))
        #expect(HUD.success("Saved") != HUD.delete("Saved"))

        let unique = Set([HUD.success("Saved"), HUD.success("Saved"), HUD.delete()])
        #expect(unique.count == 2)
    }

    @Test("The identifier of the default case includes its duration")
    func durationParticipatesInIdentity() {
        #expect(HUD.default("Copied", duration: .seconds(1)) != HUD.default("Copied", duration: .seconds(2)))
    }
}
