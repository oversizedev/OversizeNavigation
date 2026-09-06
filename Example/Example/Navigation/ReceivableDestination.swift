//
// Copyright © 2026 Alexander Romanov
// ReceivableDestination.swift, created on 06.09.2026
//

import NavigatorUI
import SwiftUI

/// A destination type some stack in the tree listens for.
///
/// `navigator.send()` is a broadcast that only the first registered handler answers, so a type
/// may be claimed once in the whole app. Dispatching the installation through the protocol lets
/// ``RootTabs/receivedDestinationType`` stay the single table both the stacks and the tests read.
protocol ReceivableDestination: Hashable, NavigationDestination {}

extension ReceivableDestination {
    @MainActor
    static func installReceiveHandler(on content: some View) -> AnyView {
        AnyView(content.navigationAutoReceive(Self.self))
    }
}

extension LayoutsDestinations: @MainActor ReceivableDestination {}
extension FlowsDestinations: @MainActor ReceivableDestination {}
extension PresentationDestinations: @MainActor ReceivableDestination {}
extension SettingsDestinations: @MainActor ReceivableDestination {}
