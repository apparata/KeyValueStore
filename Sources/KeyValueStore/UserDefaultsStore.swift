//
//  Copyright © 2025 Apparata AB. All rights reserved.
//

import Foundation

/// A generic key-value store backed by `UserDefaults`.
///
/// UserDefaultsStore provides typed load/save helpers for several common value kinds:
/// - Numeric types (e.g. `Int`, `Double`, etc.)
/// - String-like types conforming to `StringProtocol` (e.g. `String`, `Substring`)
/// - Raw representable enums backed by `Int` or `String`
/// - Arbitrary `Codable` values (encoded/decoded as JSON)
///
/// Keys are strongly-typed via an enum conforming to `RawRepresentable` (with `String` raw values) and `Hashable`.
/// All values are stored in `UserDefaults` using a configurable key prefix to avoid collisions.
///
/// Example:
/// ```swift
/// enum SettingsKey: String, Hashable {
///     case launchCount
///     case username
///     case appearance
/// }
///
/// let store = UserDefaultsStore(keyedBy: SettingsKey.self, prefixedBy: "com.example.app")
/// store.save(1, for: .launchCount)
/// let count: Int = store.load(.launchCount, default: 0)
/// ```
class UserDefaultsStore<Key: RawRepresentable & Hashable>: KeyValueStore where Key.RawValue == String {

    /// The underlying `UserDefaults` instance used for persistence.
    private let userDefaults: UserDefaults

    /// A string prefix applied to all keys before storing or retrieving them from `UserDefaults`.
    /// This helps namespacing keys and avoiding collisions with other parts of the app or frameworks.
    private let keyPrefix: String

    /// JSON encoder used when saving `Codable` values.
    private let encoder = JSONEncoder()

    /// JSON decoder used when loading `Codable` values.
    private let decoder = JSONDecoder()

    /// Creates a new user defaults-backed key-value store.
    ///
    /// - Parameters:
    ///   - userDefaults: The `UserDefaults` instance to use. Defaults to `.standard`.
    ///   - keyedBy: The key type used by this store (usually an enum). Constrained to `RawRepresentable` with `String` raw values.
    ///   - keyPrefix: A string prefix used to namespace all keys in `UserDefaults`.
    init(_ userDefaults: UserDefaults = .standard, keyedBy: Key.Type, prefixedBy keyPrefix: String) {
        self.userDefaults = userDefaults
        self.keyPrefix = keyPrefix
    }

    /// Loads a numeric value for the given key.
    ///
    /// - Parameters:
    ///   - key: The typed key to load.
    ///   - default: The default value returned if no value exists or if type casting fails.
    /// - Returns: The stored numeric value or the provided default.
    func load<T: Numeric>(_ key: Key, default: T) -> T {
        userDefaults.value(forKey: prefixed(key)) as? T ?? `default`
    }

    /// Loads a string-like value for the given key.
    ///
    /// - Parameters:
    ///   - key: The typed key to load.
    ///   - default: The default value returned if no value exists or if type casting fails.
    /// - Returns: The stored value or the provided default.
    func load<T: StringProtocol>(_ key: Key, default: T) -> T {
        userDefaults.value(forKey: prefixed(key)) as? T ?? `default`
    }

    /// Loads a raw-representable value (with `Int` raw value) for the given key.
    ///
    /// - Parameters:
    ///   - key: The typed key to load.
    ///   - default: The default value returned if no value exists or if initialization fails.
    /// - Returns: The stored value or the provided default.
    func load<T: RawRepresentable>(_ key: Key, default: T) -> T where T.RawValue == Int {
        return (userDefaults.value(forKey: prefixed(key)) as? T.RawValue).flatMap {
            T(rawValue: $0)
        } ?? `default`
    }

    /// Loads a raw-representable value (with `String` raw value) for the given key.
    ///
    /// - Parameters:
    ///   - key: The typed key to load.
    ///   - default: The default value returned if no value exists or if initialization fails.
    /// - Returns: The stored value or the provided default.
    func load<T: RawRepresentable>(_ key: Key, default: T) -> T where T.RawValue == String {
        userDefaults.string(forKey: prefixed(key)).flatMap {
            T(rawValue: $0)
        } ?? `default`
    }

    /// Loads a `Codable` value for the given key using JSON decoding.
    ///
    /// - Note: If decoding fails or if there is no stored data, the provided default is returned.
    ///
    /// - Parameters:
    ///   - key: The typed key to load.
    ///   - default: The default value returned if no value exists or if decoding fails.
    /// - Returns: The decoded value or the provided default.
    func load<T: Codable>(_ key: Key, default: T) -> T {
        do {
            guard let data = userDefaults.data(forKey: prefixed(key)) else {
                return `default`
            }
            let value = try decoder.decode(T.self, from: data)
            return value
        } catch {
            return `default`
        }
    }

    /// Saves a numeric value for the given key.
    ///
    /// - Parameters:
    ///   - value: The numeric value to store.
    ///   - key: The typed key under which to store the value.
    func save<T: Numeric>(_ value: T, for key: Key) {
        userDefaults.set(value, forKey: prefixed(key))
    }

    /// Saves a string-like value for the given key.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The typed key under which to store the value.
    func save<T: StringProtocol>(_ value: T, for key: Key) {
        userDefaults.set(value, forKey: prefixed(key))
    }

    /// Saves a raw-representable value (with `Int` raw value) for the given key.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The typed key under which to store the value.
    func save<T: RawRepresentable>(_ value: T, for key: Key) where T.RawValue == Int {
        userDefaults.set(value.rawValue, forKey: prefixed(key))
    }

    /// Saves a raw-representable value (with `String` raw value) for the given key.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The typed key under which to store the value.
    func save<T: RawRepresentable>(_ value: T, for key: Key) where T.RawValue == String {
        userDefaults.set(value.rawValue, forKey: prefixed(key))
    }

    /// Saves a `Codable` value for the given key using JSON encoding.
    ///
    /// - Parameters:
    ///   - value: The value to encode and store.
    ///   - key: The typed key under which to store the value.
    /// - Note: If encoding fails, the error is dumped to the console and no value is stored.
    func save<T: Codable>(_ value: T, for key: Key) {
        do {
            let data = try encoder.encode(value)
            userDefaults.set(data, forKey: prefixed(key))
        } catch {
            dump(error)
        }
    }

    /// Returns the fully-qualified key used in `UserDefaults` by prefixing the provided key.
    ///
    /// - Parameter key: The typed key.
    /// - Returns: A string composed of `keyPrefix` and the key's raw value.
    private func prefixed(_ key: Key) -> String {
        "\(keyPrefix)/\(key.rawValue)"
    }
}
