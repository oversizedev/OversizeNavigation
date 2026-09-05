//
// Copyright © 2026 Alexander Romanov
// KnownCheckpoints.swift, created on 05.09.2026
//

import NavigatorUI

/// Named places the flows tab can return to without knowing how deep the stack is.
struct KnownCheckpoints: NavigationCheckpoints {
    static var flows: NavigationCheckpoint<Void> { checkpoint() }
    static var flowsResult: NavigationCheckpoint<Int> { checkpoint() }
}
