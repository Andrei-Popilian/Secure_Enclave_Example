//
//  KeyTest_iOS13.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/6/21.
//

import Foundation

@available(iOS 13.0, *)
final class KeyTest_iOS13: KeyTestBase {
  /// Tests the Secure Enclave key of the given purpose.
  func testSecureEnclave(purpose: Purpose, data: Data) -> Result<String, SecurityError> {
    do {
      switch purpose {
      case .signing:
        let key = try makeSignKey()
        let keychainKey = try resetKeychainKey(key, account: "com.keychain.test.secureEnclave.iOS13")
        let message = try compare(key, keychainKey, data)
        return .success(message)

      case .keyAgreement:
        let key = try makeKeyAgreementKey()
        let keychainKey = try resetKeychainKey(key, account: "com.keychain.test.keyAgreement.secureEnclave.iOS13")
        let message = try compare(key, keychainKey)
        return .success(message)
      }
    } catch {
      guard let error = error as? SecurityError else {
        fatalError("Dev issue on handling !!!")
      }
      return .failure(error)
    }
  }
}

@available(iOS 13.0, *)
private extension KeyTest_iOS13 {
  /// Stores a key in the keychain and then reads it back.
  func resetKeychainKey<T: GenericPasswordConvertible>(_ key: T, account: String) throws -> T {
    /// Start fresh.
    try deleteKey(account: account)

    /// Store and read it back.
    try storeKey(key, account: account)

    guard let key: T = try readKey(account: account) else {
      throw SecurityError.readKeyFailed("Failed to locate stored key.")
    }

    return key
  }

  /// Stores a CryptoKit key in the keychain as a generic password.
  func storeKey<T: GenericPasswordConvertible>(_ key: T, account: String) throws {
    /// Treat the key data as a generic password.
    var query =
    [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: account,
      kSecUseDataProtectionKeychain: true,
      kSecValueData: key.rawRepresentation
    ] as [String: Any]

    if isBiometryRequired {
      query[kSecAttrAccessControl as String] = try getAccessControl()
    }

    /// Add the key data.
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw SecurityError.makeKeyFailed(status.message)
    }
  }

  /// Reads a CryptoKit key from the keychain as a generic password.
  func readKey<T: GenericPasswordConvertible>(account: String) throws -> T? {
    // Seek a generic password with the given account.
    var query =
    [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: account,
      kSecUseDataProtectionKeychain: true,
      kSecReturnData: true,
      kSecMatchLimit: kSecMatchLimitOne,
    ] as [String: Any]

    if isBiometryRequired {
      query[kSecAttrAccessControl as String] = try getAccessControl()
      query[kSecUseOperationPrompt as String] = "Access your password on the keychain"
    }

    // Find and cast the result as data.
    var item: CFTypeRef?
    switch SecItemCopyMatching(query as CFDictionary, &item) {
    case errSecSuccess:
      guard let data = item as? Data else { return nil }
      return try T(rawRepresentation: data)  // Convert back to a key.

    case errSecItemNotFound: return nil

    case let status: throw SecurityError.readKeyFailed(status.message)
    }
  }

  /// Removes any existing key with the given account.
  func deleteKey(account: String) throws {
    let query =
    [
      kSecClass: kSecClassGenericPassword,
      kSecUseDataProtectionKeychain: true,
      kSecAttrAccount: account
    ] as [String: Any]

    switch SecItemDelete(query as CFDictionary) {
    case errSecItemNotFound, errSecSuccess: break // Okay to ignore

    case let status:
      throw SecurityError.deleteKeyFailed(status.message)
    }
  }

  func getAccessControl() throws -> SecAccessControl {
    var error: Unmanaged<CFError>?
    let access =
    SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                    isBiometryRequired ? .biometryCurrentSet : .privateKeyUsage,
                                    &error)

    guard let access = access else {
      throw SecurityError.makeKeyFailed("Access control issue: \(error!.takeRetainedValue().localizedDescription)")
    }

    return access
  }
}
