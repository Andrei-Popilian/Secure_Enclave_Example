//
//  KeyTest_iOS10.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/4/21.
//

import Foundation

final class KeyTest_iOS10 {

  private let isBiometryRequired: Bool

  required init(isBiometryRequired: Bool) {
    self.isBiometryRequired = isBiometryRequired
  }

  /// Tests the Secure Enclave key of the given purpose.
  func testSecureEnclave(purpose: Purpose, data: Data) -> Result<String, SecurityError> {
    switch purpose {
    case .signing:
      do {
        let privateKey = try makeOrGetPrivateKey(withTag: "com.keychain.test.secureEnclave.iOS10")
        let signature = try sign(data: data, withKey: privateKey)
        return .success(signature)
      } catch {
        print(error.localizedDescription)
        return .failure(error as! SecurityError)
      }


      //          let key = try SecureEnclave.P256.Signing.PrivateKey()
      //            return try (compare(key, KeychainStore().roundTrip(key)), key.description)
    case .keyAgreement:
      break

      //            let key = try SecureEnclave.P256.KeyAgreement.PrivateKey()
      //            return (try compare(key, KeychainStore().roundTrip(key)), key.description)
    }

    return .success("TEST Error")
  }

  func makeOrGetPrivateKey(withTag tag: String) throws -> SecKey {
    guard let key = loadKey(tag: tag) else {
      return try makeAndStoreKey(withTag: tag)
    }

    return key
  }

  func loadKey(tag: String) -> SecKey? {
    let tag = tag.data(using: .utf8)!
    let query: [String: Any] = [
      kSecClass as String                 : kSecClassKey,
      kSecAttrApplicationTag as String    : tag,
      kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
      kSecReturnRef as String             : true
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status == errSecSuccess else {
      return nil
    }
    return (item as! SecKey)
  }

  func makeAndStoreKey(withTag tag: String) throws -> SecKey {
    removeKey(tag: tag)

    let flags: SecAccessControlCreateFlags = isBiometryRequired ? [.privateKeyUsage, .biometryCurrentSet] : .privateKeyUsage

    let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                 kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                 flags,
                                                 nil)!
    let tag = tag.data(using: .utf8)!
    let attributes: [String: Any] =
    [
      kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
      kSecAttrKeySizeInBits as String     : 256,
      kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
      kSecPrivateKeyAttrs as String :
        [
          kSecAttrIsPermanent as String       : true,
          kSecAttrApplicationTag as String    : tag,
          kSecAttrAccessControl as String     : access
        ]
    ]

    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
      throw SecurityError.makeKeyFailed((error!.takeRetainedValue() as Error).localizedDescription)
    }

    return privateKey
  }

  func removeKey(tag: String) {
    let tag = tag.data(using: .utf8)!
    let query: [String: Any] = [
      kSecClass as String                 : kSecClassKey,
      kSecAttrApplicationTag as String    : tag
    ]

    SecItemDelete(query as CFDictionary)
  }

  func sign(data: Data, withKey key: SecKey) throws -> String {
    let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256

    guard SecKeyIsAlgorithmSupported(key, .sign, algorithm) else {
      throw SecurityError.algorithmNotSupported
      //      UIAlertController.show(title: "Can't sign",
      //                                       text: "Algorith not supported",
      //                                       from: self)
    }

    // SecKeyCreateSignature call is blocking when the used key
    // is protected by biometry authentication. If that's not the case,
    // dispatching to a background thread isn't necessary.
    var error: Unmanaged<CFError>?
    let signature = SecKeyCreateSignature(key, algorithm, data as CFData, &error) as Data?
    guard signature != nil else {
      throw SecurityError.signatureInvalid((error!.takeRetainedValue() as Error).localizedDescription)
      //                  UIAlertController.show(title: "Can't sign",
      //                                               text:
      //                                               from: self)
    }
    let signatureHex = signature!.toHexString()
    return signatureHex
    //              self.signatureLabel.setTextWithAlphaAnimation("Signature: " + signatureHex)
  }
}
