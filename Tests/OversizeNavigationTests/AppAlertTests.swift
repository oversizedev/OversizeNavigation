//
// Copyright © 2026 Alexander Romanov
// AppAlertTests.swift, created on 05.09.2026
//

import Foundation
import Testing
@testable import OversizeNavigation

@MainActor
struct AppAlertTests {
    private struct SampleError: LocalizedError {
        var errorDescription: String? { "Sample failed" }
    }

    @Test("Every case has a stable identifier")
    func stableIdentifiers() {
        #expect(AppAlert.dismiss {}.id == "dismiss")
        #expect(AppAlert.delete {}.id == "delete")
        #expect(AppAlert.unsavedChanges {}.id == "unsavedChanges")
        #expect(AppAlert.discard {}.id == "discard")
        #expect(AppAlert.text("Done").id == "textTitle")
        #expect(AppAlert.appError(error: SampleError()).id == "appError")
        #expect(AppAlert.error(SampleError()).id == "error")
        #expect(AppAlert.destructive("Delete") {}.id == "destructive")
        #expect(AppAlert.default("Save") {}.id == "default")
    }

    @Test("Equality ignores the attached action")
    func equalityIgnoresAction() {
        #expect(AppAlert.delete {} == AppAlert.delete { print("other") })
        #expect(AppAlert.delete {} != AppAlert.discard {})
    }

    @Test("Hashing follows the identifier")
    func hashingFollowsIdentifier() {
        let unique = Set([AppAlert.delete {}, AppAlert.delete {}, AppAlert.discard {}])

        #expect(unique.count == 2)
    }

    @Test("Only failures produce sensory feedback")
    func feedbackOnlyForFailures() {
        #expect(AppAlert.appError(error: SampleError()).sensoryFeedback == .error)
        #expect(AppAlert.error(SampleError()).sensoryFeedback == .error)
        #expect(AppAlert.delete {}.sensoryFeedback == nil)
        #expect(AppAlert.discard {}.sensoryFeedback == nil)
        #expect(AppAlert.text("Done").sensoryFeedback == nil)
    }
}
