//
//  KeyTest_iOS10+Sign.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/6/21.
//

import Foundation

extension KeyTest_iOS10 {
  func sign(data: Data, withKey key: SecKey) throws -> String {
    let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256
    
    guard SecKeyIsAlgorithmSupported(key, .sign, algorithm) else {
      throw SecurityError.algorithmNotSupported
    }
    
    // SecKeyCreateSignature call is blocking when the used key
    // is protected by biometry authentication. If that's not the case,
    // dispatching to a background thread isn't necessary.
    var error: Unmanaged<CFError>?
    let signature = SecKeyCreateSignature(key, algorithm, data as CFData, &error) as Data?
    guard let signature = signature else {
      throw SecurityError.signatureInvalid((error!.takeRetainedValue() as Error).localizedDescription)
    }
    
    return "Signature representation contains \(signature.count) bytes."
  }
}
