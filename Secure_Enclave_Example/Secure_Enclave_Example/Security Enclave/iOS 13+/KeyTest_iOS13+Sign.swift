//
//  KeyTest_iOS13.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/4/21.
//

import Foundation
import CryptoKit

@available(iOS 13.0, *)
extension KeyTest_iOS13 {

  /// Request key-pairs from Security enclave
  func makeSignKey() throws -> SecureEnclave.P256.Signing.PrivateKey {
    do {
      // Note: if we set accessControl when generating the PrivateKey from SecureEnclave, it will request biometry authentication on signining
      //            return try SecureEnclave.P256.Signing.PrivateKey(compactRepresentable: true,
      //                                                             accessControl: try getAccessControl(),
      //                                                             authenticationContext: nil)

      return try SecureEnclave.P256.Signing.PrivateKey()
    } catch {
      throw SecurityError.makeKeyFailed(error.localizedDescription)
    }
  }

  /// Tests signing keys by signing data with one key and checking the signature with the other.
  func compare(_ key1: SecureEnclave.P256.Signing.PrivateKey,
               _ key2: SecureEnclave.P256.Signing.PrivateKey,
               _ data: Data) throws -> String {
    try key2.publicKey.isValidSignature(key1.signature(for: data), for: data) ? "\(key1.description)" : "Signing Failed"
  }
}
