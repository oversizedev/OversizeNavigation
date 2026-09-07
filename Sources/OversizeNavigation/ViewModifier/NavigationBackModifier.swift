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
                self.trigger = false
                Log.debug("🧭 [NAVIGATION] Back: \(exit)")
                deferNavigation { [exit, completion, navigator] in
                    do {
                        // Bound first: `completion?(.success(try leave()))` short-circuits on a nil completion.
                        let didLeave = try exit.leave(on: navigator)
                        completion?(.success(didLeave))
                    } catch {
                        completion?(.failure(error))
                    }
                }
            }
    }
}

public extension View {
    /// Leaves the screen whenever the trigger becomes `true`, then resets it.
    ///
    /// `exit` states how far to go — see ``NavigationExit``. The completion reports whether
    /// anything was left, and only fails for ``NavigationExit/allPresentations``.
    func navigationBack(
        _ trigger: Binding<Bool>,
        to exit: NavigationExit = .screen,
        completion: ((Result<Bool, any Error>) -> Void)? = nil
    ) -> some View {
        modifier(NavigationBackModifier(trigger: trigger, exit: exit, completion: completion))
    }
}
