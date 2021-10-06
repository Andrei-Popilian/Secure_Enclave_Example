//
//  ViewController.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/1/21.
//

import UIKit
import CryptoKit

enum Purpose {
  case signing
  case keyAgreement
}

enum SecurityError: Error {
  case algorithmNotSupported
  case makeKeyFailed(_ message: String)
  case deleteKeyFailed(_ message: String)
  case readKeyFailed(_ message: String)
  case signatureInvalid(_ message: String)
  case keyAgreementFailed(_ message: String)

}

final class ViewController: UIViewController {}
