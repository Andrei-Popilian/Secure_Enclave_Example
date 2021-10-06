//
//  KeyTest_iOS10.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/4/21.
//

import Foundation

final class KeyTest_iOS10: KeyTestBase {
  /// Tests the Secure Enclave key of the given purpose.
  func testSecureEnclave(purpose: Purpose, data: Data) -> Result<String, SecurityError> {
    do {
      switch purpose {
      case .signing:
        let privateKey = try resetKeychainKey(withTag: "com.keychain.test.secureEnclave.iOS10")
        let signature = try sign(data: data, withKey: privateKey)
        return .success(signature)
        
      case .keyAgreement:
        return .failure(.makeKeyFailed("Not implemented yet"))
      }
    } catch {
      guard let error = error as? SecurityError else {
        fatalError("Dev issue on handling !!!")
      }
      return .failure(error)
    }
  }
}

private extension KeyTest_iOS10 {
  func makeAndStoreKey(withTag tag: String) throws {
    let tag = tag.data(using: .utf8)!
    var query =
    [
      kSecAttrKeyType: kSecAttrKeyTypeEC,
      kSecAttrKeySizeInBits: 256,
      kSecAttrTokenID: kSecAttrTokenIDSecureEnclave
    ] as [String: Any]
    
    if isBiometryRequired {
      query[kSecPrivateKeyAttrs as String] =
      [
        kSecAttrIsPermanent: true,
        kSecAttrApplicationTag: tag,
        kSecAttrAccessControl: try getAccessControl()
      ]
    } else {
      query[kSecPrivateKeyAttrs as String] =
      [
        kSecAttrIsPermanent: true,
        kSecAttrApplicationTag: tag,
      ]
    }
    
    var error: Unmanaged<CFError>?
    guard let _ = SecKeyCreateRandomKey(query as CFDictionary, &error) else {
      throw SecurityError.makeKeyFailed((error!.takeRetainedValue() as Error).localizedDescription)
    }
  }
  
  func deleteKey(tag: String) throws {
    let tag = tag.data(using: .utf8)!
    let query =
    [
      kSecClass: kSecClassKey,
      kSecAttrApplicationTag: tag
    ] as [String : Any]
    
    switch SecItemDelete(query as CFDictionary) {
    case errSecItemNotFound, errSecSuccess: break // Okay to ignore
      
    case let status:
      throw SecurityError.deleteKeyFailed(status.message)
    }
  }
}

// MARK: - Private
private extension KeyTest_iOS10 {
  func resetKeychainKey(withTag tag: String) throws -> SecKey {
    // Start fresh.
    try deleteKey(tag: tag)
    
    // Store and read it back.
    try makeAndStoreKey(withTag: tag)
    
    guard let key = try readKey(tag: tag) else {
      throw SecurityError.readKeyFailed("Failed to locate stored key.")
    }
    return key
  }
  
  func readKey(tag: String) throws -> SecKey? {
    let tag = tag.data(using: .utf8)!
    let query =
    [
      kSecClass: kSecClassKey,
      kSecAttrApplicationTag: tag,
      kSecAttrKeyType: kSecAttrKeyTypeEC,
      kSecReturnRef: true
    ] as [String : Any]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status == errSecSuccess else {
      throw SecurityError.readKeyFailed(status.message)
    }
    
    return (item as! SecKey)
  }
  
  func getAccessControl() throws -> SecAccessControl {
    var error: Unmanaged<CFError>?
    let access =
    SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                    isBiometryRequired ? [.privateKeyUsage ,.biometryCurrentSet] : .privateKeyUsage,
                                    &error)
    
    guard let access = access else {
      throw SecurityError.makeKeyFailed("Access control issue: \(error!.takeRetainedValue().localizedDescription)")
    }
    
    return access
  }
}
