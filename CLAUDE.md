# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
swift build          # Build the package
swift build -c release  # Release build
```

No Makefile — use `swift build` directly. CI runs via `workflows/` using GitHub Actions shared workflows from `oversizedev/GithubWorkflows`.

## Local Development

`Package.swift` auto-detects local Oversize packages: if `~/Developer/Packages/OversizeCore` exists, all Oversize dependencies load from `../` paths; otherwise they resolve from GitHub. No manual switching needed.

## Architecture

### Layout Views

Four layout types live under `Sources/OversizeNavigation/`, each in its own folder with a `View` + `ViewModifier` file pair:

| Folder | View | Use case |
|---|---|---|
| `NavigationLayout/` | `NavigationLayoutView` | General scrollable content |
| `NavigationListLayout/` | `NavigationListLayoutView` | List-optimized, supports `ListLayoutStyle` |
| `NavigationCoverLayout/` | `NavigationCoverLayoutView` | Hero/cover with optional parallax |
| `NavigationListCoverLayout/` | `NavigationListCoverLayoutView` | List with cover header |

All four share the same modifier surface: `.backButtonHidden()`, `.backConfirmationDialog()`.

### Navigator Integration

All layout views read `@Environment(\.navigator)` from the [Navigator](https://github.com/hmlongco/Navigator) package. Key APIs used internally:

- `navigator.back()` — pop/dismiss
- `navigator.send<T>(_ value: T)` — send data to coordinator (used by `.navigationMove`)
- `navigator.isPresented` + `navigator.count` — determine back button style (chevron.left for stack, xmark for modal root)

SwiftUI reports `isPresented == true` for a `NavigationSplitView` detail column, so a stack that
roots a column looks presented to Navigator and the layouts would show a close button that
collapses the column. Screens that root a column or a tab opt out with `.backButtonHidden()`,
which applies only while the stack is at its root — pushed screens keep their back button.

### Navigation Modifiers (`ViewModifier/`)

- `.navigationBack(_ trigger: Binding<Bool>)` — programmatic pop
- `.navigationMove(_ item: Binding<T?>)` — navigate with data via `navigator.send()`
- `.backConfirmationDialog(_ content:)` — confirmation before back; also sets `interactiveDismissDisabled`
- `.navigationBarAppearanceConfiguration()` — OversizeUI bar styling (iOS < 26 only via `#if os(iOS)`)

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
