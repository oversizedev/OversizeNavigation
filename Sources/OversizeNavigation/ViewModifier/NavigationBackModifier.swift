//
// Copyright © 2025 Alexander Romanov
// NavigationBackModifier.swift, created on 09.06.2025
//

import NavigatorUI
import OversizeCore
import SwiftUI

private struct NavigationBackModifier: ViewModifier {
    @Binding var trigger: Bool
    let exit: NavigationExit
    let completion: ((Result<Bool, any Error>) -> Void)?

    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, trigger in
                guard trigger else { return }
                // Reset before leaving: the action can tear this view down, and the write would
                // then land on a binding nobody owns any more.
                self.trigger = false
                Log.debug("🧭 [NAVIGATION] Back: \(exit)")
                do {
                    // Bind the result before reporting it: `completion?(.success(try leave()))`
                    // short-circuits on a nil completion and never leaves at all.
                    let didLeave = try exit.leave(on: navigator)
                    completion?(.success(didLeave))
                } catch {
                    completion?(.failure(error))
                }
            }
    }
}

public extension View {
    /// Leaves the screen whenever the trigger becomes `true`, then resets it.
    ///
    /// `exit` states how far to go, because the depths are not interchangeable and the call site
    /// is where the difference matters — see ``NavigationExit``. The default pops one screen,
    /// which is what a back button does.
    ///
    /// The completion reports whether anything was left. It only ever fails for
    /// ``NavigationExit/allPresentations``, which a screen marked ``navigationLocked()`` blocks.
    func navigationBack(
        _ trigger: Binding<Bool>,
        to exit: NavigationExit = .screen,
        completion: ((Result<Bool, any Error>) -> Void)? = nil
    ) -> some View {
        modifier(NavigationBackModifier(trigger: trigger, exit: exit, completion: completion))
    }
}
