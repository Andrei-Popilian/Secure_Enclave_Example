//
//  GenericPasswordConvertible.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/1/21.
//

import Foundation
import CryptoKit

/// The interface needed for SecKey conversion.
protocol GenericPasswordConvertible: CustomStringConvertible {
  /// Creates a key from a raw representation.
  init<D>(rawRepresentation data: D) throws where D: ContiguousBytes
  
  /// A raw representation of the key.
  var rawRepresentation: Data { get }
}

extension GenericPasswordConvertible {
  /// A string version of the key for visual inspection.
  /// IMPORTANT: Never log the actual key data.
  public var description: String {
    rawRepresentation.withUnsafeBytes { bytes in
      "Key representation contains \(bytes.count) bytes."
    }
  }
}

// Ensure that Secure Enclave keys are generic password convertible.
@available(iOS 13.0, *)
extension SecureEnclave.P256.KeyAgreement.PrivateKey: GenericPasswordConvertible {
  init<D>(rawRepresentation data: D) throws where D: ContiguousBytes {
    try self.init(dataRepresentation: data.dataRepresentation)
  }
  
  var rawRepresentation: Data {
    dataRepresentation  // Contiguous bytes repackaged as a Data instance.
  }
}

@available(iOS 13.0, *)
extension SecureEnclave.P256.Signing.PrivateKey: GenericPasswordConvertible {
  init<D>(rawRepresentation data: D) throws where D: ContiguousBytes {
    try self.init(dataRepresentation: data.dataRepresentation)
  }
  
  var rawRepresentation: Data {
    dataRepresentation  // Contiguous bytes repackaged as a Data instance.
  }
}

extension ContiguousBytes {
  /// A Data instance created safely from the contiguous bytes without making any copies.
  var dataRepresentation: Data {
    withUnsafeBytes { bytes in
      let cfdata = CFDataCreateWithBytesNoCopy(nil, bytes.baseAddress?.assumingMemoryBound(to: UInt8.self), bytes.count, kCFAllocatorNull)
      return ((cfdata as NSData?) as Data?) ?? Data()
    }
  }
}

