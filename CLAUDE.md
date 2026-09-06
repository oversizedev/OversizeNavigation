# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
swift build          # Build the package
swift build -c release  # Release build
```

No Makefile — use `swift build` directly. CI runs via `.github/workflows/ci.yml`, partly from the
shared workflows in `oversizedev/GithubWorkflows`.

`Example/Example.xcodeproj` must stay at `objectVersion = 77`. Xcode 27 upgrades it to 110 on any
save — including one `xcodebuild` performs while running the tests — and the CI runner's Xcode
then refuses to open the project at all. `preferredProjectObjectVersion` does not prevent this, so
check the line after any Xcode session; the `lint-example-project` CI job fails loudly if it slips.

## Local Development

`Package.swift` auto-detects local Oversize packages: if `~/Developer/Packages/OversizeCore` exists, all Oversize dependencies load from `../` paths; otherwise they resolve from GitHub. No manual switching needed.

## Architecture

### Layout Views

Four layout types live under `Sources/OversizeNavigation/`, each in its own folder with a
view + `ViewModifier` file pair:

| Folder | View | Use case |
|---|---|---|
| `NavigationLayout/` | `NavigationLayout` | General scrollable content |
| `NavigationListLayout/` | `NavigationListLayout` | List-optimized, supports `ListLayoutStyle` |
| `NavigationCoverLayout/` | `NavigationCoverLayout` | Hero/cover with optional parallax |
| `NavigationListCoverLayout/` | `NavigationListCoverLayout` | List with cover header |

All four share the same modifier surface: `.backButtonHidden()`, `.backConfirmationDialog()`.

`Deprecated/` holds the previous generation of the same four (`NavigationLayoutView`,
`NavigationListLayoutView`, `NavigationCoverLayoutView`, `NavigationListCoverLayoutView`).
Keep them building, do not add to them, and route new work to the names above.

### Back Button

Whether a layout installs its own back control, and which glyph it uses, is decided by
`Models/BackButtonPolicy.swift` — a plain value over `isPresented`, `count`,
`backButtonHidden(_:)` and whether a confirmation is set. It exists so that the rule is stated
once and tested directly (`Tests/OversizeNavigationTests/BackButtonPolicyTests.swift`) instead of
being re-derived inside each view. Every layout renders the control through the single
`ViewModifier/NavigationLayoutBackToolbarModifier.swift`; nothing else should build that toolbar.

SwiftUI reports `isPresented == true` for a `NavigationSplitView` detail column, so a stack that
roots a column looks presented to Navigator and the layouts would show a close button that
collapses the column. Screens that root a column or a tab opt out with `.backButtonHidden()`,
which applies only while the stack is at its root — pushed screens keep their back button.

### Navigator Integration

The layouts read `@Environment(\.navigator)` from the [Navigator](https://github.com/hmlongco/Navigator) package. Key APIs used internally:

- `navigator.back()` — pop/dismiss
- `navigator.send<T>(_ value: T)` — send data to coordinator (used by `.navigationMove`)
- `navigator.isPresented` + `navigator.count` — the inputs to `BackButtonPolicy`

### Navigation Invariants

Defects found in consumer apps (Linker, Journal) trace back to four rules. The Example app follows
them and `Example/ExampleUITests` pins each one down:

- **One receive handler per destination type in the whole tree.** `navigator.send()` is a broadcast:
  `NavigationSendValues` hands the value to the handler that registered first and logs
  `additional receive handlers ignored` for the rest. Two stacks receiving the same type means a
  push lands in a tab nobody is looking at, which reads as "nothing happened". The Example
  states the mapping once in `RootTabs.receivedDestinationType`; the stacks install from it and
  `ExampleTests` asserts on it, so the two cannot drift.
- **`.navigationOpen` for a screen navigating to its own stack, `.navigationMove` / `navigator.send()`
  only for a real broadcast** (deep link, tab switch from outside, share extension). `navigationOpen`
  navigates on the navigator in the environment, so a pushed screen — or a screen inside a sheet with
  its own stack — presents where it actually lives instead of handing the intent to the root.
- **Never nest `ManagedNavigationStack` inside another one.** Wrapping a `TabView` in a stack while
  every tab builds its own gives the tab roots no navigation bar on iPhone, delays presentations
  requested from pushed screens until the next navigation event, and stops programmatic dismiss from
  taking effect. iPad `NavigationSplitView` hides the symptom, so it looks like an iPhone-only bug.
- **Hold a selected tab in `@State`, not `@SceneStorage`.** `onNavigationReceive(assign:)` runs but
  the assignment does not take on a scene-stored binding, so every cross-tab deep link dies silently.

One more, outside this package but affecting anything hosting it: modifiers that read
`UIApplication.shared` during view construction (`.screenSize` in OversizeUI's `coreServices()`)
must be applied **below** `.presentationHUDRoot()`. Applied above the `ZStack` it creates, the
accessibility tree stops being published — the app renders, but XCUITest sees no text and no buttons.

### Navigation Modifiers (`ViewModifier/`)

A screen states an intent through a binding and the modifier performs it, so no screen reads
`@Environment(\.navigator)` or imports `NavigatorUI`. That import belongs to the app's navigation
layer alone — destination conformances, stacks, roots and routers. `Example/Example/Screens` is the
reference for the split.

- `.navigationBack(_ trigger: Binding<Bool>)` — programmatic pop
- `.navigationOpen(_ destination: Binding<T?>)` — navigate on the navigator this screen lives on
- `.navigationMove(_ item: Binding<T?>)` — navigate with data via `navigator.send()`
- `.navigationMove(values: Binding<[AnyHashable]?>)` — broadcast an ordered list, one receiver per type
- `.navigationRoute(_ route: Binding<Route?>)` — perform a cross-module `NavigationRoutes` value
- `.navigationDismiss(_ trigger: Binding<Bool>)` — dismiss the presentation this screen lives in
- `.navigationDismissAny(_ trigger:completion:)` — dismiss every presentation; fails on a locked screen
- `.navigationLocked()` — block a global dismiss while this screen is on the stack
- `.navigationCheckpoint(_:)` / `.navigationCheckpoint(_:completion:)` — name a place to return to
- `.navigationReturn(to:trigger:)` / `.navigationReturn(to:value:)` — return there, optionally with a value
- `.backConfirmationDialog(_ content:)` — confirmation before back; also sets `interactiveDismissDisabled`
- `.navigationBarAppearanceConfiguration()` — OversizeUI bar styling (iOS < 26 only via `#if os(iOS)`)

`.navigationCheckpoint()` and `.navigationLocked()` mirror NavigatorUI names and are marked
`@_disfavoredOverload`, the same trick as `NavigationLink(to:)`: a file importing both modules gets
NavigatorUI's, a file importing only this package gets ours. Their bodies call the NavigatorUI
overload by the same name, so the attribute is the only thing keeping them from recursing into
themselves. Nothing in `Tests/` covers that — the test target imports NavigatorUI and therefore
hits the original. The screens under `Example/Example/Screens`, which import this package alone,
are the regression test; do not "simplify" them into importing NavigatorUI.

Every modifier in the family takes a binding, performs the intent, and **resets the binding**, so
the same intent can be stated twice in a row. A new one must do the same.

Read-only stack state comes from `@Environment(\.navigationInfo)` — `depth`, `isRoot`,
`isPresented`, `canReturn(to:)` — instead of reading the navigator directly.

### HUD System (`HUD/`)

`HUDState` is an `@Observable` class accessed via `@Environment(\.hud)`. It manages a stack capped at 3 HUDs with auto-dismiss (2–4 s). Place `.presentationHUDRoot()` once at the root; use `.presentationHUD($hud)` on child views.

Pre-built `HUD` enum cases: `.success`, `.error`, `.delete`, `.archive`, `.favorite`, `.edited`, `.default(text:duration:)`.

### Alert System (`Alert/`)

`AppAlert` enum covers common cases: `.dismiss`, `.delete`, `.discard`, `.unsavedChanges`, `.destructive`, `.appError`. Use `.presentationAlert($alert)` on any view.

Custom alert types conform to `Alertable` (Identifiable + Equatable + Hashable).

### Platform Conditionals

iOS < 26 uses custom `ArrowLeft` image from `Media.xcassets`. iOS 26+ uses `Image(systemName: "chevron.left")` / `"xmark"`. Always gate with `#available(iOS 26, *)` or `#if os(iOS)` where needed — existing code is the reference.

## File Organization

- New layout type → new folder `NavigationXxxLayout/` with `NavigationXxxLayoutView.swift` + `NavigationXxxLayoutViewModifier.swift`
- New navigation modifier → `ViewModifier/`
- New enum config (Alert, HUD variant) → matching existing folder (`Alert/`, `HUD/`, `Models/`)
- Tab protocols → `Tabs/`
