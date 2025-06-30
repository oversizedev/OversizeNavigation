# OversizeNavigation

A comprehensive SwiftUI navigation framework that provides three specialized layout types with advanced navigation controls, back button customization, and seamless integration with the Oversize design system.

## Overview

OversizeNavigation simplifies navigation in SwiftUI applications by offering pre-built navigation layouts optimized for different use cases. Whether you need a standard layout, list-optimized interface, or hero/cover layout with parallax effects, this framework provides the tools you need with built-in confirmation dialogs and programmatic navigation control.

## Features

- **Three Navigation Layout Types**: Standard, List, and Cover layouts for different UI patterns
- **Back Confirmation System**: Built-in confirmation dialogs to prevent accidental navigation
- **Custom Navigation Bar Styling**: Comprehensive appearance customization
- **Programmatic Navigation Control**: Modifier-based navigation management
- **Parallax Cover Effects**: Dynamic cover layouts with scroll-based animations
- **Hide/Show Controls**: Flexible back button visibility management
- **Navigator Integration**: Seamless integration with NavigatorUI for advanced routing
- **OversizeUI Integration**: Built on the Oversize design system

## Installation

### Swift Package Manager

Add OversizeNavigation to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/oversizedev/OversizeNavigation.git", .upToNextMajor(from: "1.0.0"))
]
```

Then import the framework in your SwiftUI views:

```swift
import OversizeNavigation
```

## Platform Support

- **iOS**: 17.0+
- **macOS**: 14.0+
- **tvOS**: 17.0+
- **watchOS**: 10.0+

## Navigation Layout Types

### 1. NavigationLayoutView

The standard navigation layout perfect for general content views.

```swift
import SwiftUI
import OversizeNavigation

struct ContentView: View {
    var body: some View {
        NavigationStack {
            NavigationLayoutView("Home") {
                VStack(spacing: 20) {
                    Text("Welcome to the app!")
                    Button("Navigate") {
                        // Navigation logic
                    }
                }
                .padding()
            }
        }
    }
}
```

#### With Custom Background

```swift
NavigationLayoutView(
    "Custom Background",
    content: {
        Text("Content with custom background")
            .padding()
    },
    background: { Color.blue.opacity(0.1) }
)
```

#### With Scroll Handling

```swift
NavigationLayoutView(
    "Scrollable Content",
    onScroll: { offset in
        print("Scroll offset: \(offset)")
    }
) {
    LazyVStack {
        ForEach(1...100, id: \.self) { item in
            Text("Item \(item)")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
```

### 2. NavigationListLayoutView

Optimized layout for list-based interfaces with enhanced performance for large datasets.

```swift
NavigationListLayoutView("User List") {
    LazyVStack(spacing: 0) {
        ForEach(users, id: \.id) { user in
            UserRowView(user: user)
                .padding()
                .background(Color.backgroundSecondary)
        }
    }
}
```

### 3. NavigationCoverLayoutView

Hero/cover layout with parallax effects and customizable cover content.

```swift
NavigationCoverLayoutView(
    "Profile",
    coverHeight: 300
) {
    // Main content
    LazyVStack {
        ProfileInfoView()
        PostListView()
    }
} cover: {
    // Cover content with parallax effect
    AsyncImage(url: profileImageURL) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
    } placeholder: {
        Color.gray
    }
}
```

#### Cover Layout Styles

```swift
NavigationCoverLayoutView("Parallax Cover", coverHeight: 350) {
    ContentView()
} cover: {
    CoverImageView()
}
.coverStyle(.parallax)  // Default parallax effect
.contentCornerRadius(16) // Rounded content corners
```

Static cover (no parallax):
```swift
.coverStyle(.static)
```

## Navigation Controls

### Back Button Customization

#### Hide Back Button
```swift
NavigationLayoutView("No Back Button") {
    ContentView()
}
.backButtonHidden()
```

#### Back Confirmation Dialogs

Prevent accidental navigation with confirmation dialogs:

```swift
NavigationLayoutView("Edit Profile") {
    ProfileEditView()
}
.backConfirmationDialog(.discard)  // Pre-built confirmation
```

#### Custom Confirmation Dialog

```swift
NavigationLayoutView("Custom Form") {
    FormView()
}
.backConfirmationDialog(
    title: "Discard Changes?",
    message: "You have unsaved changes that will be lost.",
    confirmationButtonTitle: "Discard",
    cancelButtonTitle: "Keep Editing"
)
```

#### Pre-built Confirmation Types

```swift
// Dismiss confirmation
.backConfirmationDialog(.dismiss)

// Discard changes confirmation
.backConfirmationDialog(.discard)
```

## Navigation Modifiers

### Programmatic Navigation

#### Navigate Back Programmatically

```swift
struct MyView: View {
    @State private var shouldNavigateBack = false
    
    var body: some View {
        NavigationLayoutView("Settings") {
            VStack {
                Button("Save & Exit") {
                    saveSettings()
                    shouldNavigateBack = true
                }
            }
        }
        .navigationBack($shouldNavigateBack)
    }
}
```

#### Navigate with Data

```swift
struct ListView: View {
    @State private var selectedItem: Item?
    
    var body: some View {
        NavigationLayoutView("Items") {
            ForEach(items) { item in
                Button(item.title) {
                    selectedItem = item
                }
            }
        }
        .navigationMove($selectedItem)
    }
}
```

## Navigation Bar Styling

Apply consistent navigation bar appearance across your app:

```swift
struct RootView: View {
    var body: some View {
        NavigationStack {
            ContentView()
        }
        .naviagtionBarAppearenceConfiguration()
    }
}
```

This modifier automatically configures:
- Custom back button indicators
- Title text attributes
- Navigation bar transparency
- Layout margins
- Color schemes

## Alert System Integration

OversizeNavigation includes a comprehensive alert system:

```swift
enum CustomAlert: Alertable {
    case deleteConfirmation(action: () -> Void)
    case networkError(message: String)
}

// Usage in views
.alert(for: CustomAlert.self) { alert in
    switch alert {
    case .deleteConfirmation(let action):
        Alert(
            title: Text("Delete Item"),
            message: Text("This action cannot be undone"),
            primaryButton: .destructive(Text("Delete"), action: action),
            secondaryButton: .cancel()
        )
    case .networkError(let message):
        Alert(
            title: Text("Network Error"),
            message: Text(message),
            dismissButton: .default(Text("OK"))
        )
    }
}
```

## Complete Example

Here's a comprehensive example showing multiple navigation layouts:

```swift
import SwiftUI
import OversizeNavigation

struct MainApp: View {
    var body: some View {
        NavigationStack {
            NavigationLayoutView("Main Menu") {
                VStack(spacing: 20) {
                    NavigationLink("User Profile") {
                        ProfileView()
                    }
                    
                    NavigationLink("Settings") {
                        SettingsView()
                    }
                    
                    NavigationLink("Photo Gallery") {
                        GalleryView()
                    }
                }
                .padding()
            }
        }
        .naviagtionBarAppearenceConfiguration()
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationCoverLayoutView(
            "Profile",
            coverHeight: 250
        ) {
            LazyVStack(alignment: .leading, spacing: 16) {
                Text("About")
                    .font(.headline)
                Text("Profile information and details...")
                
                Text("Recent Activity")
                    .font(.headline)
                ForEach(1...10, id: \.self) { item in
                    Text("Activity \(item)")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        } cover: {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    Text("John Doe")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .coverStyle(.parallax)
        .contentCornerRadius(16)
    }
}

struct SettingsView: View {
    @State private var hasUnsavedChanges = false
    
    var body: some View {
        NavigationListLayoutView("Settings") {
            LazyVStack(spacing: 0) {
                SettingsRow(title: "Notifications", action: {})
                SettingsRow(title: "Privacy", action: {})
                SettingsRow(title: "Account", action: {})
            }
        }
        .backConfirmationDialog(
            hasUnsavedChanges ? .discard : nil
        )
    }
}

struct SettingsRow: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.backgroundPrimary)
        }
        .foregroundColor(.primary)
    }
}
```

## License

OversizeModels is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

---

<div align="center">

**Made with ❤️ by the Oversize**

</div>
