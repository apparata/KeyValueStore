//
//  Copyright © 2025 Apparata AB. All rights reserved.
//

import Foundation

/// A simple, in-memory implementation of `KeyValueStore`.
///
/// InMemoryKeyValueStore keeps values in a local dictionary for the lifetime of the instance.
/// It is particularly useful for unit tests, previews, or ephemeral state where persistence
/// across launches is not required.
///
/// Supported value kinds:
/// - Numeric types (e.g. `Int`, `Double`, etc.)
/// - String-like types conforming to `StringProtocol` (e.g. `String`, `Substring`)
/// - Raw representable enums backed by `Int` or `String`
/// - Arbitrary `Codable` values (encoded/decoded as JSON and stored as `Data`)
///
/// Keys are strongly typed via a `RawRepresentable & Hashable` type whose raw value is `String`
/// (typically an enum). Values are kept in-memory only and are not synchronized across processes.
///
/// Example:
/// ```swift
/// enum SettingsKey: String, Hashable {
///     case launchCount
///     case username
///     case preferredTheme
/// }
///
/// let store = InMemoryKeyValueStore(keyedBy: SettingsKey.self)
/// store.save(1, for: .launchCount)
/// let count: Int = store.load(.launchCount, default: 0) // -> 1
/// ```
public class InMemoryKeyValueStore<Key: RawRepresentable & Hashable>: KeyValueStore where Key.RawValue == String {

    /// Backing storage for values kept in memory.
    private var values: [Key: Any] = [:]

    /// JSON encoder used when saving `Codable` values.
    private let encoder = JSONEncoder()

    /// JSON decoder used when loading `Codable` values.
    private let decoder = JSONDecoder()

    /// Creates a new in-memory key-value store.
    ///
    /// - Parameters:
    ///   - keyedBy: The key type used by this store (usually an enum).
    ///   - initialContent: Optional initial content to seed the store with.
    ///                     For `Codable` values, provide `Data` produced by `JSONEncoder`.
    public init(keyedBy: Key.Type, initialContent: [Key: Any] = [:]) {
        self.values = initialContent
    }

    /// Loads a numeric value for the given key.
    ///
    /// - Parameters:
    ///   - key: The typed key to load.
    ///   - default: The default value returned if no value exists or if type casting fails.
    /// - Returns: The stored numeric value or the provided default.
    public func load<T: Numeric>(_ key: Key, default: T) -> T {
        values[key] as? T ?? `default`
    }

    /// Loads a string-like value for the given key.
    ///
    /// - Parameters:
    ///   - key: The typed key to load.
    ///   - default: The default value returned if no value exists or if type casting fails.
    /// - Returns: The stored value or the provided default.
    public func load<T: StringProtocol>(_ key: Key, default: T) -> T {
        values[key] as? T ?? `default`
    }

    /// Loads a raw-representable value (with `Int` raw value) for the given key.
    ///
    /// - Parameters:
    ///   - key: The typed key to load.
    ///   - default: The default value returned if no value exists or if initialization fails.
    /// - Returns: The stored value or the provided default.
    public func load<T: RawRepresentable>(_ key: Key, default: T) -> T where T.RawValue == Int {
        return (values[key] as? T.RawValue).flatMap {
            T(rawValue: $0)
        } ?? `default`
    }

    /// Loads a raw-representable value (with `String` raw value) for the given key.
    ///
    /// - Parameters:
    ///   - key: The typed key to load.
    ///   - default: The default value returned if no value exists or if initialization fails.
    /// - Returns: The stored value or the provided default.
    public func load<T: RawRepresentable>(_ key: Key, default: T) -> T where T.RawValue == String {
        (values[key] as? String).flatMap {
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
    public func load<T: Codable>(_ key: Key, default: T) -> T {
        do {
            guard let data = values[key] as? Data else {
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
    public func save<T: Numeric>(_ value: T, for key: Key) {
        values[key] = value
    }

    /// Saves a string-like value for the given key.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The typed key under which to store the value.
    public func save<T: StringProtocol>(_ value: T, for key: Key) {
        values[key] = value
    }

    /// Saves a raw-representable value (with `Int` raw value) for the given key.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The typed key under which to store the value.
    public func save<T: RawRepresentable>(_ value: T, for key: Key) where T.RawValue == Int {
        values[key] = value.rawValue
    }

    /// Saves a raw-representable value (with `String` raw value) for the given key.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The typed key under which to store the value.
    public func save<T: RawRepresentable>(_ value: T, for key: Key) where T.RawValue == String {
        values[key] = value.rawValue
    }

    /// Saves a `Codable` value for the given key using JSON encoding.
    ///
    /// - Parameters:
    ///   - value: The value to encode and store.
    ///   - key: The typed key under which to store the value.
    /// - Note: If encoding fails, the error is dumped to the console and no value is stored.
    public func save<T: Codable>(_ value: T, for key: Key) {
        do {
            let data = try encoder.encode(value)
            values[key] = data
        } catch {
            dump(error)
        }
    }
}
