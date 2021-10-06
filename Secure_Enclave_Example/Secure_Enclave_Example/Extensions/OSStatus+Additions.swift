//
//  KeychainStoreError.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/1/21.
//

import Foundation

extension OSStatus {

  /// A human readable message for the status.
  var message: String {
    return (SecCopyErrorMessageString(self, nil) as String?) ?? String(self)
  }
}
