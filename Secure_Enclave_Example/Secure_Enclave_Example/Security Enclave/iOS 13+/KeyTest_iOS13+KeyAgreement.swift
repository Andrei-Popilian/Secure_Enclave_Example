//
//  KeyTest_iOS13+KeyAgreement.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/6/21.
//

import Foundation
import CryptoKit

@available(iOS 13.0, *)
extension KeyTest_iOS13 {

  /// Request key-pairs from Security enclave
  func makeKeyAgreementKey() throws -> SecureEnclave.P256.KeyAgreement.PrivateKey {
    do {
      /// Note: if we set accessControl when generating the PrivateKey from SecureEnclave, it will request biometry authentication on sharedSecretFromKeyAgreement
      //      return try SecureEnclave.P256.KeyAgreement.PrivateKey(compactRepresentable: true,
      //                                                            accessControl: try getAccessControl(),
      //                                                            authenticationContext: nil)

      return try SecureEnclave.P256.KeyAgreement.PrivateKey()
    } catch {
      throw SecurityError.makeKeyFailed(error.localizedDescription)
    }
  }

  /// Tests agreement keys by producing and comparing two shared secrets.
  func compare(_ key1: SecureEnclave.P256.KeyAgreement.PrivateKey,
               _ key2: SecureEnclave.P256.KeyAgreement.PrivateKey) throws -> String {

    do {
      let sharedSecret1 = try key1.sharedSecretFromKeyAgreement(with: key2.publicKey)
      let sharedSecret2 = try key2.sharedSecretFromKeyAgreement(with: key1.publicKey)

      return sharedSecret1 == sharedSecret2 ? "SharedSecret: \(key1.description)" : "Fail"
    } catch {
      throw SecurityError.keyAgreementFailed(error.localizedDescription)
    }
  }
}
