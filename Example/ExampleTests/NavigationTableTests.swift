//
// Copyright © 2026 Alexander Romanov
// NavigationTableTests.swift, created on 05.09.2026
//

import NavigatorUI
import Testing
@testable import Example

@MainActor
struct RootTabsTests {
    @Test("Every tab is reachable from both the tab bar and the sidebar")
    func tabsAndSidebarCoverEveryCase() {
        #expect(RootTabs.tabs == RootTabs.allCases)
        #expect(RootTabs.sidebar == RootTabs.allCases)
    }

    @Test("Tabs keep the order the app is documented with")
    func tabOrder() {
        #expect(RootTabs.tabs == [.layouts, .flows, .presentation, .settings])
    }

    @Test("Identifiers are unique and stable")
    func uniqueIdentifiers() {
        let identifiers = RootTabs.allCases.map(\.id)

        #expect(Set(identifiers).count == identifiers.count)
        #expect(identifiers == ["layouts", "flows", "presentation", "settings"])
    }

    @Test("Every tab is labelled")
    func everyTabIsLabelled() {
        for tab in RootTabs.allCases {
            #expect(tab.title.isEmpty == false)
        }
    }
}

@MainActor
struct DestinationMethodTests {
    @Test("Only the sheet demo leaves the stack")
    func layoutsMethods() {
        #expect(LayoutsDestinations.backConfirmationSheet.method == .managedSheet)

        for destination in LayoutsDestinations.catalog where destination != .backConfirmationSheet {
            #expect(destination.method == .push)
        }
    }

    @Test("Flow destinations pick the presentation they need")
    func flowMethods() {
        #expect(FlowsDestinations.page(1).method == .push)
        #expect(FlowsDestinations.checkpointResult.method == .push)
        #expect(FlowsDestinations.locked.method == .push)
        #expect(FlowsDestinations.sheet.method == .managedSheet)
        #expect(FlowsDestinations.cover.method == .managedCover)
    }

    @Test("Presentation and settings destinations are pushed")
    func pushedMethods() {
        for destination in PresentationDestinations.catalog {
            #expect(destination.method == .push)
        }
        #expect(SettingsDestinations.about.method == .push)
    }

    @Test("Pages are identified by their number")
    func pageIdentity() {
        #expect(FlowsDestinations.page(1) != FlowsDestinations.page(2))
        #expect(FlowsDestinations.page(1).id == "page(1)")
    }
}

@MainActor
struct LayoutsCatalogTests {
    @Test("The catalog lists every layout destination")
    func catalogIsComplete() {
        #expect(LayoutsDestinations.catalog.count == 7)
        #expect(Set(LayoutsDestinations.catalog.map(\.id)).count == LayoutsDestinations.catalog.count)
    }

    @Test("Every catalog row is labelled")
    func everyRowIsLabelled() {
        for destination in LayoutsDestinations.catalog {
            #expect(destination.title.isEmpty == false)
            #expect(destination.subtitle.isEmpty == false)
        }
    }
}

/// A value sent through the navigator is delivered to the handler registered for its type, and
/// only to the first one. Nothing checks that at compile time, so the routing table each stack
/// declares with `navigationAutoReceive` is mirrored here and asserted on.
@MainActor
struct ReceiveHandlerTests {
    private static let handlers: [(tab: RootTabs, destination: Any.Type)] = [
        (.layouts, LayoutsDestinations.self),
        (.flows, FlowsDestinations.self),
        (.presentation, PresentationDestinations.self),
        (.settings, SettingsDestinations.self),
    ]

    private static var receivedTypeNames: Set<String> {
        Set(handlers.map { String(describing: $0.destination) })
    }

    @Test("Each destination type is received by exactly one stack")
    func oneHandlerPerType() {
        #expect(Self.receivedTypeNames.count == Self.handlers.count)
    }

    @Test("Every tab installs a handler")
    func everyTabReceivesSomething() {
        #expect(Set(Self.handlers.map(\.tab)) == Set(RootTabs.allCases))
    }

    @Test("A route only sends values some stack is waiting for")
    func routesStayWithinTheTable() {
        let received = Self.receivedTypeNames

        for route in [ExampleRoutes.about, .hud, .deepPage] {
            for value in route.values.dropFirst() {
                #expect(received.contains(String(describing: type(of: value))))
            }
        }
    }

    @Test("A route pushes into the tab it selected")
    func routesPushIntoTheTabTheySelect() {
        let owner: [String: RootTabs] = Dictionary(
            uniqueKeysWithValues: Self.handlers.map { (String(describing: $0.destination), $0.tab) }
        )

        for route in [ExampleRoutes.about, .hud, .deepPage] {
            guard let tab = route.values.first as? RootTabs else {
                Issue.record("\(route) does not start by selecting a tab")
                continue
            }

            for value in route.values.dropFirst() {
                #expect(owner[String(describing: type(of: value))] == tab)
            }
        }
    }
}
