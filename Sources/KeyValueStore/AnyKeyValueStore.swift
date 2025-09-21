//
//  Copyright © 2025 Apparata AB. All rights reserved.
//

import Foundation

// MARK: - Type Erasure

/// A type-erased wrapper for any `KeyValueStore`.
///
/// Use `AnyKeyValueStore` to hide the concrete store implementation (e.g. `UserDefaultsStore`),
/// which is useful for dependency injection or when exposing an API that should not leak
/// the underlying persistence mechanism.
///
/// Usage example:
/// ```swift
/// // 1) Define your key type
/// enum SettingsKey: String, Hashable {
///     case launchCount
///     case username
///     case preferredTheme
/// }
///
/// // 2) Create a concrete store (e.g. backed by UserDefaults)
/// let concreteStore = UserDefaultsStore(.standard, keyedBy: SettingsKey.self, prefixedBy: "com.example.app")
///
/// // 3) Type-erase it for injection or API exposure
/// let store: AnyKeyValueStore<SettingsKey> = AnyKeyValueStore(concreteStore)
/// // Alternatively:
/// // let store = concreteStore.eraseToAnyKeyValueStore()
///
/// // 4) Use the type-erased store just like the concrete one
/// store.save(1, for: .launchCount)
/// let count: Int = store.load(.launchCount, default: 0)
///
/// store.save("alice", for: .username)
/// let username: String = store.load(.username, default: "guest")
///
/// // RawRepresentable example (String-backed)
/// enum Theme: String {
///     case system, light, dark
/// }
/// store.save(Theme.dark, for: .preferredTheme)
/// let theme: Theme = store.load(.preferredTheme, default: .system)
/// ```
///
/// You can also persist any `Codable` type via JSON encoding/decoding.
/// For example:
/// ```swift
/// struct Profile: Codable, Equatable {
///     var name: String
///     var age: Int
/// }
///
/// let profileKey = SettingsKey.username // or define a dedicated key
/// let defaultProfile = Profile(name: "guest", age: 0)
///
/// store.save(Profile(name: "Alice", age: 30), for: .username)
/// let loaded: Profile = store.load(.username, default: defaultProfile)
/// ```
public struct AnyKeyValueStore<K: RawRepresentable & Hashable>: KeyValueStore where K.RawValue == String {
    private let box: _AnyKeyValueStoreBase<K>

    public init<S: KeyValueStore>(_ base: S) where S.Key == K {
        self.box = _KeyValueStoreBox(base)
    }

    // Forwarding
    public func load<T: Numeric>(_ key: K, default: T) -> T {
        box.loadNumeric(key, default: `default`)
    }

    public func load<T: StringProtocol>(_ key: K, default: T) -> T {
        box.loadString(key, default: `default`)
    }

    public func load<T: RawRepresentable>(_ key: K, default: T) -> T where T.RawValue == Int {
        box.loadRawInt(key, default: `default`)
    }

    public func load<T: RawRepresentable>(_ key: K, default: T) -> T where T.RawValue == String {
        box.loadRawString(key, default: `default`)
    }

    public func load<T: Codable>(_ key: K, default: T) -> T {
        box.loadCodable(key, default: `default`)
    }

    public func save<T: Numeric>(_ value: T, for key: K) {
        box.saveNumeric(value, key: key)
    }

    public func save<T: StringProtocol>(_ value: T, for key: K) {
        box.saveString(value, key: key)
    }

    public func save<T: RawRepresentable>(_ value: T, for key: K) where T.RawValue == Int {
        box.saveRawInt(value, key: key)
    }

    public func save<T: RawRepresentable>(_ value: T, for key: K) where T.RawValue == String {
        box.saveRawString(value, key: key)
    }

    public func save<T: Codable>(_ value: T, for key: K) {
        box.saveCodable(value, key: key)
    }
}

// MARK: - Private Box

private class _AnyKeyValueStoreBase<K: RawRepresentable> where K.RawValue == String {
    func loadNumeric<T: Numeric>(_ key: K, default: T) -> T { fatalError("Must override") }
    func loadString<T: StringProtocol>(_ key: K, default: T) -> T { fatalError("Must override") }
    func loadRawInt<T: RawRepresentable>(_ key: K, default: T) -> T where T.RawValue == Int { fatalError("Must override") }
    func loadRawString<T: RawRepresentable>(_ key: K, default: T) -> T where T.RawValue == String { fatalError("Must override") }
    func loadCodable<T: Codable>(_ key: K, default: T) -> T { fatalError("Must override") }

    func saveNumeric<T: Numeric>(_ value: T, key: K) { fatalError("Must override") }
    func saveString<T: StringProtocol>(_ value: T, key: K) { fatalError("Must override") }
    func saveRawInt<T: RawRepresentable>(_ value: T, key: K) where T.RawValue == Int { fatalError("Must override") }
    func saveRawString<T: RawRepresentable>(_ value: T, key: K) where T.RawValue == String { fatalError("Must override") }
    func saveCodable<T: Codable>(_ value: T, key: K) { fatalError("Must override") }
}

private final class _KeyValueStoreBox<Base: KeyValueStore>: _AnyKeyValueStoreBase<Base.Key> {
    private let base: Base

    init(_ base: Base) { self.base = base }

    override func loadNumeric<T: Numeric>(_ key: Base.Key, default: T) -> T {
        base.load(key, default: `default`)
    }

    override func loadString<T: StringProtocol>(_ key: Base.Key, default: T) -> T {
        base.load(key, default: `default`)
    }

    override func loadRawInt<T: RawRepresentable>(_ key: Base.Key, default: T) -> T where T.RawValue == Int {
        base.load(key, default: `default`)
    }

    override func loadRawString<T: RawRepresentable>(_ key: Base.Key, default: T) -> T where T.RawValue == String {
        base.load(key, default: `default`)
    }

    override func loadCodable<T: Codable>(_ key: Base.Key, default: T) -> T {
        base.load(key, default: `default`)
    }

    override func saveNumeric<T: Numeric>(_ value: T, key: Base.Key) {
        base.save(value, for: key)
    }

    override func saveString<T: StringProtocol>(_ value: T, key: Base.Key) {
        base.save(value, for: key)
    }

    override func saveRawInt<T: RawRepresentable>(_ value: T, key: Base.Key) where T.RawValue == Int {
        base.save(value, for: key)
    }

    override func saveRawString<T: RawRepresentable>(_ value: T, key: Base.Key) where T.RawValue == String {
        base.save(value, for: key)
    }

    override func saveCodable<T: Codable>(_ value: T, key: Base.Key) {
        base.save(value, for: key)
    }
}

// MARK: - Convenience

extension KeyValueStore {
    /// Returns a type-erased wrapper over `self`.
    public func eraseToAnyKeyValueStore() -> AnyKeyValueStore<Key> { AnyKeyValueStore(self) }
}
