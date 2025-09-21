# KeyValueStore

A Swift package that provides a type-safe, protocol-based key-value storage abstraction with multiple backing implementations.

## Overview

KeyValueStore offers a unified interface for persisting and retrieving strongly-typed values using enum-based keys. It supports various data types including numeric values, strings, raw representable types, and codable objects.

## Features

- **Type Safety**: Strongly-typed keys prevent runtime errors from typos
- **Multiple Backends**: UserDefaults, in-memory, and custom implementations
- **Type Erasure**: `AnyKeyValueStore` for dependency injection scenarios
- **Codable Support**: Automatic JSON encoding/decoding for complex types
- **SwiftUI Integration**: Works seamlessly with `@Observable` classes

## Requirements

- iOS 18.0+
- macOS 15.0+
- tvOS 18.0+
- visionOS 2.0+
- Swift 6.2+

## Usage

### Basic Setup

First, define your keys using a string-based enum:

```swift
enum AppSettingsKey: String {
    case userName
    case isFirstLaunch
    case theme
}
```

### UserDefaults Backend

```swift
import KeyValueStore

// Create a UserDefaults-backed store
let store = UserDefaultsStore(
    keyedBy: AppSettingsKey.self,
    prefixedBy: "MyApp"
)

// Save values
store.save("John Doe", for: .userName)
store.save(false, for: .isFirstLaunch)

// Load values with defaults
let userName = store.load(.userName, default: "Guest")
let isFirstLaunch = store.load(.isFirstLaunch, default: true)
```

### In-Memory Backend

```swift
// Create an in-memory store for testing
let store = InMemoryKeyValueStore(
    keyedBy: AppSettingsKey.self,
    initialContent: [
        .userName: "Test User",
        .isFirstLaunch: false
    ]
)
```

### Raw Representable Types

```swift
enum AppColorScheme: String, CaseIterable {
    case light
    case dark
    case system
}

// Save and load enums
store.save(AppColorScheme.dark, for: .theme)
let theme = store.load(.theme, default: AppColorScheme.system)
```

### Codable Types

```swift
struct UserPreferences: Codable {
    let fontSize: Double
    let enableNotifications: Bool
}

let preferences = UserPreferences(fontSize: 16.0, enableNotifications: true)
store.save(preferences, for: .userPreferences)

let loadedPreferences = store.load(.userPreferences, default: UserPreferences(
    fontSize: 14.0,
    enableNotifications: false
))
```

### SwiftUI Integration

Create an observable settings class for SwiftUI:

```swift
import SwiftUI

@Observable
final class AppSettings {
    enum Key: String {
        case colorScheme
        case userName
    }
    
    var colorScheme: AppColorScheme {
        didSet {
            store.save(colorScheme, for: .colorScheme)
        }
    }
    
    var userName: String {
        didSet {
            store.save(userName, for: .userName)
        }
    }
    
    private let store: AnyKeyValueStore<Key>
    
    init(store: AnyKeyValueStore<Key>? = nil) {
        self.store = store ?? UserDefaultsStore(
            keyedBy: Key.self,
            prefixedBy: "AppSettings"
        ).eraseToAnyKeyValueStore()
        
        // Load initial values
        self.colorScheme = self.store.load(.colorScheme, default: .system)
        self.userName = self.store.load(.userName, default: "Guest")
    }
}

// Usage in SwiftUI
struct ContentView: View {
    let settings = AppSettings()
    
    var body: some View {
        VStack {
            Text("Hello, \(settings.userName)!")
            
            Picker("Color Scheme", selection: $settings.colorScheme) {
                ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                    Text(scheme.rawValue.capitalized).tag(scheme)
                }
            }
        }
    }
}
```

### Testing and Previews

Create mock stores for testing and SwiftUI previews:

```swift
#if DEBUG
extension AppSettings {
    static func mock() -> AppSettings {
        let store = InMemoryKeyValueStore(keyedBy: Key.self, initialContent: [
            .colorScheme: AppColorScheme.system,
            .userName: "Preview User"
        ])
        return AppSettings(store: store.eraseToAnyKeyValueStore())
    }
}

// Use in SwiftUI previews
#Preview {
    ContentView()
        .environment(AppSettings.mock())
}
#endif
```

### Type Erasure

Use `AnyKeyValueStore` for dependency injection:

```swift
class SettingsManager {
    private let store: AnyKeyValueStore<AppSettingsKey>
    
    init(store: AnyKeyValueStore<AppSettingsKey>) {
        self.store = store
    }
    
    func resetToDefaults() {
        store.save("Guest", for: .userName)
        store.save(true, for: .isFirstLaunch)
    }
}

// Usage
let userDefaultsStore = UserDefaultsStore(keyedBy: AppSettingsKey.self, prefixedBy: "MyApp")
let manager = SettingsManager(store: userDefaultsStore.eraseToAnyKeyValueStore())
```

## Supported Types

KeyValueStore supports the following value types:

- **Numeric**: `Int`, `Double`, `Float`, `Int64`, etc.
- **String**: `String` and other `StringProtocol` conforming types
- **Raw Representable**: Enums with `Int` or `String` raw values
- **Codable**: Any type conforming to `Codable`

## Key Components

The package consists of several key components:

- **`KeyValueStore`**: The main protocol defining the storage interface
- **`UserDefaultsStore`**: UserDefaults-backed implementation with key prefixing
- **`InMemoryKeyValueStore`**: In-memory implementation for testing
- **`AnyKeyValueStore`**: Type-erased wrapper for protocol abstraction

## License

This project is licensed under the BSD Zero Clause License. See LICENSE file for more info.
