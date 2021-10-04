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
  case signatureInvalid(_ message: String)

}


final class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()


  }
  @IBAction func doTest(_ sender: Any) {
    if SecurityEnclaveManager.isSecureEnclaveAvailable() {
      print("Has security Enclave support")


      let data = "TEST Data".data(using: .utf8)!

      if #available(iOS 13.0, *) {
        let keyTest = KeyTest_iOS13(isBiometryRequired: true)
        let result = keyTest.testSecureEnclave(purpose: .signing, data: data)

        switch result {
        case let .success(signatureKeyHex):
          print("Success: \(signatureKeyHex)")

        case let .failure(error):
          print(error)
        }
      } else {
        print("Lower than iOS 13")
        // Fallback on earlier versions
      }
    }
  }


//
//      if #available(iOS 13.0, *) {
//        do {
//          try KeyTest().testSecureEnclave(purpose: .signing)
//        } catch {
//          guard let error = error as? KeychainStoreError else {
//            print("Generic error message")
//            return
//          }
//          print(error.message)
//        }
//      } else {
//        print("Something for iOS 12")
//        // Fallback on earlier versions
//      }
//
//    } else {
//      print("Doesn't have security Enclave Support")
//    }
}


