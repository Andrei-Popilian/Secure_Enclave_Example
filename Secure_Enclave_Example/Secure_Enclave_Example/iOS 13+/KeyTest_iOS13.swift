//
//  KeyTest_iOS13.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/4/21.
//

import Foundation
import CryptoKit

@available(iOS 13.0, *)
final class KeyTest_iOS13 {

  private let isBiometryRequired: Bool

  required init(isBiometryRequired: Bool) {
    self.isBiometryRequired = isBiometryRequired
  }
  /// Tests the Secure Enclave key of the given purpose.
   func testSecureEnclave(purpose: Purpose, data: Data) -> Result<String, SecurityError> {
     do {
    switch purpose {
    case .signing:
      let key = try SecureEnclave.P256.Signing.PrivateKey()
      let message = try compare(key, KeychainStore().roundTrip(key), data)
      return .success(message)

    case .keyAgreement:
      let key = try SecureEnclave.P256.KeyAgreement.PrivateKey()
      let message = try compare(key, KeychainStore().roundTrip(key))
      return .success(message)
    }
    } catch {
      print(error.localizedDescription)
      return .failure(error as! SecurityError)
    }
  }

  /// Tests signing keys by signing data with one key and checking the signature with the other.
  private func compare(_ key1: SecureEnclave.P256.Signing.PrivateKey,
                       _ key2: SecureEnclave.P256.Signing.PrivateKey,
                       _ data: Data) throws -> String {
    try key2.publicKey.isValidSignature(key1.signature(for: data), for: data) ? "Success: \(key1.description)" : "Fail"
  }

  /// Tests agreement keys by producing and comparing two shared secrets.
  private func compare(_ key1: SecureEnclave.P256.KeyAgreement.PrivateKey,
                       _ key2: SecureEnclave.P256.KeyAgreement.PrivateKey) throws -> String {
    let sharedSecret1 = try key1.sharedSecretFromKeyAgreement(with: key2.publicKey)
    let sharedSecret2 = try key2.sharedSecretFromKeyAgreement(with: key1.publicKey)
    return sharedSecret1 == sharedSecret2 ? "Success: \(key1.description)" : "Fail"
  }
}
