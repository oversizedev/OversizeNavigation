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

They carry the same per-platform annotation OversizeUI puts on `LayoutView` and friends —
`@available(iOS, introduced: 17.0, deprecated: 18.0, renamed: "NavigationLayout")`, one line per
platform. Deprecating at the version where the replacement became available means the package,
which still deploys to iOS 17, builds warning-free while a consumer on iOS 18 gets the fix-it.

The fix-it is not a drop-in swap: the old views take `LayoutView.ScrollAction`
(`(CGPoint, CGFloat)`) where the new ones take `(CGFloat, CGFloat)`, and the default background
moved from `backgroundPrimary` to `backgroundSecondary`. Read the call site after applying it.

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

- `.navigationBack(_ trigger:to:completion:)` — leave the screen; `to:` is a `NavigationExit`
- `.navigationOpen(_ destination: Binding<T?>)` — navigate on the navigator this screen lives on
- `.navigationMove(_ item: Binding<T?>)` — navigate with data via `navigator.send()`
- `.navigationMove(values: Binding<[AnyHashable]?>)` — broadcast an ordered list, one receiver per type
- `.navigationRoute(_ route: Binding<Route?>)` — perform a cross-module `NavigationRoutes` value
- `.navigationLocked()` — block a global dismiss while this screen is on the stack
- `.navigationCheckpoint(_:)` / `.navigationCheckpoint(_:completion:)` — name a place to return to
- `.navigationReturn(to:trigger:)` / `.navigationReturn(to:value:)` — return there, optionally with a value
- `.backConfirmationDialog(_ content:)` — confirmation before back; also sets `interactiveDismissDisabled`
- `.navigationBarAppearanceConfiguration()` — OversizeUI bar styling (iOS < 26 only via `#if os(iOS)`)

**One intent, one modifier.** Leaving a screen was three modifiers — `navigationBack`,
`navigationDismiss`, `navigationDismissAny` — whose names did not say how far each went, and a
screen at the root of a sheet left identically under the first two because NavigatorUI's `back()`
is `pop() || dismiss()`. They are now one `.navigationBack(_:to:completion:)` over
`Models/NavigationExit.swift` (`.screen` / `.presentation` / `.allPresentations`), so the depth is
stated at the call site instead of chosen by picking a name. The old two are `@available(deprecated)`
shims forwarding to it. `NavigationExit.leave(on:)` holds the whole depth→operation mapping and is
asserted directly in `Tests/OversizeNavigationTests/NavigationExitTests.swift`; keep it there rather
than re-deriving it inside a modifier. A new modifier that splits one intent across several names
belongs in this shape too.

Several of these look like duplicates of NavigatorUI and are not: they are the facade. A method
declared in another module's `extension View` cannot be called without importing that module, so
every intent a screen states has to be restated here or the no-import rule collapses. Deleting
`.navigationMove`, `.navigationBack`, `.navigationReturn(to:trigger:)`, `.navigationCheckpoint`
or `.navigationLocked` because "NavigatorUI already has it" means putting `import NavigatorUI` back
into every screen. Do not.

Each overlap picks one of two strategies, and a new modifier must pick one too:

- **Same signature + `@_disfavoredOverload`** — `.navigationCheckpoint()`, `.navigationLocked()`,
  `NavigationLink(to:)`. A file importing both modules gets NavigatorUI's, a file importing only
  this package gets ours. Their bodies call the NavigatorUI overload by the same name, and the
  attribute is what breaks the tie. If NavigatorUI renames or re-signs one, the call binds to
  itself and the `some View` return type has nothing to infer from, so **the package stops
  building** — the breakage is a compile error here, not a runtime trap.
- **A deliberately different name** — `.navigationMove` for `navigationSend`, `.navigationReturn`
  for `navigationReturnToCheckpoint`, `.navigationOpen` for `navigate(to:)`. No ambiguity to break,
  and the name says what this package means by it.

Four of them also carry behaviour NavigatorUI does not have, so they are not swappable even in
principle:

| Modifier | Delta over NavigatorUI |
|---|---|
| `.navigationMove(values:)` | takes `[AnyHashable]` — a deep link mixes a tab value with the destination it pushes; `navigationSend(values:)` is a homogeneous `[T]` |
| `.navigationBack(_:to:completion:)` | one modifier over all three depths, and it reports a `Result`; NavigatorUI spreads them across `navigationDismiss`/`navigationDismissAny`, has no declarative wrapper for `back()` at all, and swallows the `dismissAny` throw with `try?` — a throw that is meaningful, since `.navigationLocked()` is what raises it |
| `.navigationReturn(to:value:)` | returns to a checkpoint **with a value**; NavigatorUI has no declarative form of that |
| `.navigationRoute` | NavigatorUI exposes `navigator.perform(route:)` imperatively only |

`.navigationOpen` is the remaining deliberate difference: it takes `Hashable & Equatable` rather
than `some NavigationDestination`, because a feature package states destinations whose
`NavigationDestination` conformance is added in the app target and therefore invisible there.
`Tests/OversizeNavigationTests/NavigationModifierSignatureTests.swift` pins that constraint by
type. The cost is that a genuinely wrong value is caught at runtime rather than by the compiler,
so the modifier asserts in debug before falling back to a plain push.

Every modifier in the family takes a binding, performs the intent, and **resets the binding**, so
the same intent can be stated twice in a row. A new one must do the same.

The screens under `Example/Example/Screens` import this package alone and are what proves the
facade is complete; the `lint-screen-imports` CI job fails if one of them reaches for NavigatorUI.
Do not "simplify" them into importing it.

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

Two availability floors, and they are not a mistake: the package deploys to iOS 17 / macOS 14 /
tvOS 17 / watchOS 10 because that is what `Deprecated/` supports, while every current
`Navigation*Layout` is annotated one major higher (iOS 18 / macOS 15 / tvOS 18 / watchOS 11 /
visionOS 2) — the version where the OversizeUI layout it wraps became available. Do not "fix" the
gap by raising the package floor; that would drop the deprecated layer that still has callers.
visionOS is declared at 2.0 rather than 1.0 because OversizeUI itself starts there, and SwiftPM
rejects a floor below a direct dependency's.

### macOS

macOS is a supported platform, built by CI and exercised by the Example app and its UI tests, not
an afterthought. Four things behave differently there and are worth knowing before writing a fix:

- **`.managedCover` presents nothing.** NavigatorUI wraps `.fullScreenCover` in
  `#if os(iOS) || os(tvOS) || os(watchOS)`, so a destination asking for a cover on macOS sets state
  nothing renders and the screen silently never appears. `Models/NavigationMethodPlatform.swift`
  states the substitution once as `.platformManagedCover` / `.platformCover`; destinations use
  those rather than re-deriving it. Its `#if` mirrors NavigatorUI's own condition instead of
  naming macOS, so visionOS — which has no cover either — is covered by the same line.
- **The back control is a labelled button.** A Mac toolbar labels its controls, so
  `NavigationLayoutBackToolbarModifier` renders text there instead of a glyph. Which word it is
  comes from `BackButtonPolicy.backButtonRole` — `.close` at the root of a presentation, `.pop`
  otherwise — the same value that picks the glyph on iOS and the accessibility identifier
  (`navigationBack.close` / `navigationBack.pop`) on both. A `#if os(macOS)` branch that decides
  the label on its own is how macOS ended up labelling every pop "Cancel".
- **`navigationBarAppearanceConfiguration()` is a no-op**, since it configures `UINavigationBar`.
  Mac bar styling has to come from the toolbar itself.
- **`.sensoryFeedback` is inert**, so the HUD and alert feedback paths do nothing on macOS. Keep
  the calls — they cost nothing and stay correct on the platforms that have haptics.
- **An abrupt kill can poison window restoration.** A macOS app killed mid-flight — a crashed
  UI test runner is enough — can record a scene with zero windows in a store keyed by bundle id
  and served by a system daemon; every later launch then shows a menu bar over no window, which a
  UI test reads as an empty accessibility tree. `-ApplePersistenceIgnoreState` does not cure it
  and neither does deleting the container. `ExampleApp` opts out of restoration and
  `ExampleLaunch.resetPersistedState()` wipes the app-side record under UI testing; if a local
  machine is already poisoned, build with a fresh `PRODUCT_BUNDLE_IDENTIFIER` to get out. The
  crash that plants it is why `ExampleUITestCase.setUp` must stay synchronous: an XCTest failure
  with `continueAfterFailure = false` cannot unwind through an async `setUp` and kills the runner.

The Example app starts on the split root on macOS and the tab root elsewhere
(`RootType.defaultForPlatform`), and `ExampleUITestCase` branches per platform — a Mac has no tab
bar, publishes `navigationTitle` into the window rather than a navigation bar, and renders a
confirmation dialog as a sheet with a real Cancel button instead of a `PopoverDismissRegion`. Test
bodies stay platform-free; only the helpers branch.

## File Organization

- New layout type → new folder `NavigationXxxLayout/` with `NavigationXxxLayoutView.swift` + `NavigationXxxLayoutViewModifier.swift`
- New navigation modifier → `ViewModifier/`
- New enum config (Alert, HUD variant) → matching existing folder (`Alert/`, `HUD/`, `Models/`)
- Tab protocols → `Tabs/`
