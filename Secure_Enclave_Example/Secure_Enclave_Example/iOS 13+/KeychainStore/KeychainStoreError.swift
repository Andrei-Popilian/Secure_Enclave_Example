//
//  KeychainStoreError.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/1/21.
//

import Foundation

/// An error we can throw when something goes wrong.
struct KeychainStoreError: Error, CustomStringConvertible {
  var message: String

  init(_ message: String) {
    self.message = message
  }

  public var description: String {
    return message
  }
}

extension OSStatus {

  /// A human readable message for the status.
  var message: String {
    return (SecCopyErrorMessageString(self, nil) as String?) ?? String(self)
  }
}
