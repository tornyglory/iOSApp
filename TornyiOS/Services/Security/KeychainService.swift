import Foundation
import Security

/// Secure storage service using iOS Keychain for sensitive data
/// Provides encrypted storage for auth tokens, passwords, and other credentials
class KeychainService {

    // MARK: - Singleton
    static let shared = KeychainService()
    private init() {}

    // MARK: - Constants
    private let service = "com.torny.app"

    // MARK: - Keys
    struct Keys {
        static let authToken = "auth_token"
        static let tokenExpiry = "token_expiry"
        static let currentUserId = "current_user_id"
    }

    // MARK: - Public Methods

    /// Save a string value to Keychain
    /// - Parameters:
    ///   - value: The string value to save
    ///   - key: The key to associate with the value
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            print("🔐 KeychainService: Failed to convert string to data")
            return false
        }
        return save(data, forKey: key)
    }

    /// Save data to Keychain
    /// - Parameters:
    ///   - data: The data to save
    ///   - key: The key to associate with the data
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func save(_ data: Data, forKey key: String) -> Bool {
        // First, try to update existing item
        if update(data, forKey: key) {
            return true
        }

        // If update failed, add new item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("🔐 KeychainService: Successfully saved \(key)")
            return true
        } else {
            print("🔐 KeychainService: Failed to save \(key) with status: \(status)")
            return false
        }
    }

    /// Save a Date value to Keychain
    /// - Parameters:
    ///   - date: The date to save
    ///   - key: The key to associate with the date
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func save(_ date: Date, forKey key: String) -> Bool {
        let data = Data(date.timeIntervalSince1970.bitPattern.littleEndian.bytes)
        return save(data, forKey: key)
    }

    /// Retrieve a string value from Keychain
    /// - Parameter key: The key associated with the value
    /// - Returns: The string value if found, nil otherwise
    func getString(forKey key: String) -> String? {
        guard let data = getData(forKey: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// Retrieve data from Keychain
    /// - Parameter key: The key associated with the data
    /// - Returns: The data if found, nil otherwise
    func getData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess {
            return item as? Data
        } else if status == errSecItemNotFound {
            print("🔐 KeychainService: Item not found for key: \(key)")
        } else {
            print("🔐 KeychainService: Failed to retrieve \(key) with status: \(status)")
        }

        return nil
    }

    /// Retrieve a Date value from Keychain
    /// - Parameter key: The key associated with the date
    /// - Returns: The date if found, nil otherwise
    func getDate(forKey key: String) -> Date? {
        guard let data = getData(forKey: key),
              data.count == 8 else {
            return nil
        }

        let timeInterval = TimeInterval(bitPattern: UInt64(littleEndian: data.withUnsafeBytes { $0.load(as: UInt64.self) }))
        return Date(timeIntervalSince1970: timeInterval)
    }

    /// Delete an item from Keychain
    /// - Parameter key: The key of the item to delete
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess {
            print("🔐 KeychainService: Successfully deleted \(key)")
            return true
        } else if status == errSecItemNotFound {
            print("🔐 KeychainService: Item not found for deletion: \(key)")
            return true // Consider this a success since the item doesn't exist
        } else {
            print("🔐 KeychainService: Failed to delete \(key) with status: \(status)")
            return false
        }
    }

    /// Delete all items from Keychain for this app
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func deleteAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            print("🔐 KeychainService: Successfully cleared all items")
            return true
        } else {
            print("🔐 KeychainService: Failed to clear all items with status: \(status)")
            return false
        }
    }

    // MARK: - Private Methods

    /// Update an existing item in Keychain
    /// - Parameters:
    ///   - data: The new data
    ///   - key: The key of the item to update
    /// - Returns: True if successful, false otherwise
    private func update(_ data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        return status == errSecSuccess
    }
}

// MARK: - Convenience Extensions

extension KeychainService {

    // MARK: - Auth Token Management

    /// Save authentication token securely
    /// - Parameters:
    ///   - token: The auth token
    ///   - expiryDate: When the token expires
    /// - Returns: True if successful
    func saveAuthToken(_ token: String, expiryDate: Date) -> Bool {
        let tokenSaved = save(token, forKey: Keys.authToken)
        let expirySaved = save(expiryDate, forKey: Keys.tokenExpiry)
        return tokenSaved && expirySaved
    }

    /// Retrieve authentication token
    /// - Returns: The auth token if valid and not expired, nil otherwise
    func getAuthToken() -> String? {
        // Check if token has expired
        if let expiry = getDate(forKey: Keys.tokenExpiry),
           expiry <= Date() {
            print("🔐 KeychainService: Auth token has expired")
            clearAuthToken()
            return nil
        }

        return getString(forKey: Keys.authToken)
    }

    /// Check if auth token is valid and not expired
    /// - Returns: True if token is valid, false otherwise
    func isAuthTokenValid() -> Bool {
        guard let _ = getString(forKey: Keys.authToken),
              let expiry = getDate(forKey: Keys.tokenExpiry) else {
            return false
        }

        return expiry > Date()
    }

    /// Get time remaining until token expires
    /// - Returns: Time interval until expiry, or 0 if expired/not found
    func getTokenTimeRemaining() -> TimeInterval {
        guard let expiry = getDate(forKey: Keys.tokenExpiry) else {
            return 0
        }

        return max(0, expiry.timeIntervalSinceNow)
    }

    /// Check if token will expire soon (within 24 hours)
    /// - Returns: True if expiring soon, false otherwise
    func isTokenExpiringSoon() -> Bool {
        let timeRemaining = getTokenTimeRemaining()
        return timeRemaining > 0 && timeRemaining < 24 * 60 * 60 // 24 hours
    }

    /// Clear authentication token and related data
    /// - Returns: True if successful
    @discardableResult
    func clearAuthToken() -> Bool {
        let tokenDeleted = delete(forKey: Keys.authToken)
        let expiryDeleted = delete(forKey: Keys.tokenExpiry)
        let userIdDeleted = delete(forKey: Keys.currentUserId)
        return tokenDeleted && expiryDeleted && userIdDeleted
    }

    /// Save current user ID
    /// - Parameter userId: The user ID to save
    /// - Returns: True if successful
    func saveCurrentUserId(_ userId: String) -> Bool {
        return save(userId, forKey: Keys.currentUserId)
    }

    /// Get current user ID
    /// - Returns: The user ID if found, nil otherwise
    func getCurrentUserId() -> String? {
        return getString(forKey: Keys.currentUserId)
    }
}

// MARK: - Helper Extensions

extension FixedWidthInteger {
    var bytes: [UInt8] {
        withUnsafeBytes(of: self) { Array($0) }
    }
}