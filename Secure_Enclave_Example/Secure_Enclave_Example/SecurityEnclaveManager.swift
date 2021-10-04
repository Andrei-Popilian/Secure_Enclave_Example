//
//  SecurityEnclaveManager.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/1/21.
//

import Foundation
import CryptoKit
import LocalAuthentication

enum SecurityEnclaveManager {

  static func isSecureEnclaveAvailable() -> Bool {
    guard #available(iOS 13.0, *) else {
      return hasSecureEnclave()
    }

    return SecureEnclave.isAvailable
  }
}

// MARK: - Handling for < iOS 13
private extension SecurityEnclaveManager {

  static func hasSecureEnclave() -> Bool {
    !isSimulator() && hasBiometrics()
  }

  static func isSimulator() -> Bool {
    TARGET_OS_SIMULATOR == 1
  }

  static func hasBiometrics() -> Bool {
    let localAuthContext = LAContext()
    var error: NSError?

    /// Policies can have certain requirements which, when not satisfied, would always cause
    /// the policy evaluation to fail - e.g. a passcode set, a fingerprint
    /// enrolled with Touch ID or a face set up with Face ID. This method allows easy checking
    /// for such conditions.
    let isValidPolicy = localAuthContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

    guard isValidPolicy == true else {

      if #available(iOS 11, *) {
        if error?.code != LAError.biometryNotAvailable.rawValue {
          return true
        } else {
          return false
        }
      }
      else {
        if error?.code != LAError.touchIDNotAvailable.rawValue {
          return true
        } else {
          return false
        }
      }
    }
    return isValidPolicy
  }
}
