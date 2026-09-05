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
