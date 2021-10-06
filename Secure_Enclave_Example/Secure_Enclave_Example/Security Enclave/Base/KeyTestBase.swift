//
//  KeyTestBase.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/6/21.
//

import Foundation

class KeyTestBase {
  let isBiometryRequired: Bool

  required init(isBiometryRequired: Bool) {
    self.isBiometryRequired = isBiometryRequired
  }
}
