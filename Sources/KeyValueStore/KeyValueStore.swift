//
//  Copyright © 2025 Apparata AB. All rights reserved.
//

import Foundation

// MARK: - KeyValueStore

/// A protocol that defines a generic key-value storage interface.
///
/// The `KeyValueStore` protocol provides methods to load and save
/// values associated with strongly typed keys. It supports primitive
/// types such as numeric and string values, as well as types that
/// conform to `RawRepresentable` with `Int` or `String` raw values.
///
/// Conforming types can provide custom backing storage such as
/// `UserDefaults`, databases, or in-memory dictionaries.
///
public protocol KeyValueStore {

    associatedtype Key: RawRepresentable & Hashable where Key.RawValue == String

    /// Loads a numeric value for the given key.
    ///
    /// - Parameters:
    ///   - key: The strongly typed key to retrieve the value for.
    ///   - default: The value to return if the key does not exist.
    /// - Returns: The stored numeric value, or the provided default.
    ///
    func load<T: Numeric>(_ key: Key, default: T) -> T

    /// Loads a string value for the given key.
    ///
    /// - Parameters:
    ///   - key: The strongly typed key to retrieve the value for.
    ///   - default: The value to return if the key does not exist.
    /// - Returns: The stored string value, or the provided default.
    ///
    func load<T: StringProtocol>(_ key: Key, default: T) -> T

    /// Loads a raw representable value backed by an integer raw value.
    ///
    /// - Parameters:
    ///   - key: The strongly typed key to retrieve the value for.
    ///   - default: The value to return if the key does not exist.
    /// - Returns: The stored raw representable value, or the provided default.
    ///
    func load<T: RawRepresentable>(_ key: Key, default: T) -> T where T.RawValue == Int

    /// Loads a raw representable value backed by a string raw value.
    ///
    /// - Parameters:
    ///   - key: The strongly typed key to retrieve the value for.
    ///   - default: The value to return if the key does not exist.
    /// - Returns: The stored raw representable value, or the provided default.
    ///
    func load<T: RawRepresentable>(_ key: Key, default: T) -> T where T.RawValue == String

    /// Loads a codable value for the given key.
    ///
    /// - Parameters:
    ///   - key: The strongly typed key to retrieve the value for.
    ///   - default: The value to return if the key does not exist or decoding fails.
    /// - Returns: The stored codable value, or the provided default.
    ///
    func load<T: Codable>(_ key: Key, default: T) -> T

    /// Saves a numeric value for the given key.
    ///
    /// - Parameters:
    ///   - value: The numeric value to store.
    ///   - key: The strongly typed key to associate the value with.
    ///
    func save<T: Numeric>(_ value: T, for key: Key)

    /// Saves a string value for the given key.
    ///
    /// - Parameters:
    ///   - value: The string value to store.
    ///   - key: The strongly typed key to associate the value with.
    ///
    func save<T: StringProtocol>(_ value: T, for key: Key)

    /// Saves a raw representable value backed by an integer raw value.
    ///
    /// - Parameters:
    ///   - value: The raw representable value to store.
    ///   - key: The strongly typed key to associate the value with.
    ///
    func save<T: RawRepresentable>(_ value: T, for key: Key) where T.RawValue == Int

    /// Saves a raw representable value backed by a string raw value.
    ///
    /// - Parameters:
    ///   - value: The raw representable value to store.
    ///   - key: The strongly typed key to associate the value with.
    ///
    func save<T: RawRepresentable>(_ value: T, for key: Key) where T.RawValue == String

    /// Saves a codable value for the given key.
    ///
    /// - Parameters:
    ///   - value: The codable value to store.
    ///   - key: The strongly typed key to associate the value with.
    ///
    func save<T: Codable>(_ value: T, for key: Key)
}
