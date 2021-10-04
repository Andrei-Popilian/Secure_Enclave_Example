//
//  Data+Additions.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/4/21.
//

import Foundation

extension Data {
  public func toHexString() -> String {
    reduce("", {$0 + String(format: "%02X ", $1)})
  }
}
