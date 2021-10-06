//
//  SignViewController.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/5/21.
//

import UIKit

final class SignViewController: UIViewController {

  @IBOutlet var biometryControl: UISegmentedControl!
  @IBOutlet var securityEnclaveSupportLabel: UILabel!
  @IBOutlet var statusLabel: UILabel!
  @IBOutlet var runningLabel: UILabel!

  private let data = "TEST Data".data(using: .utf8)!

  private var isBiometryEnabled: Bool { biometryControl.selectedSegmentIndex == 0 }

  override func viewDidLoad() {
    var className = ""
    if #available(iOS 13.0, *) {
      className = String(describing: KeyTest_iOS13.self)
    } else {
      className = String(describing: KeyTest_iOS10.self)
    }

    runningLabel.text = "Running code from: \(className) class"
    let isSecurityEnclaveActive = SecurityEnclaveManager.isSecureEnclaveAvailable()

    securityEnclaveSupportLabel.text = isSecurityEnclaveActive ? "YES" : "NO"
    securityEnclaveSupportLabel.textColor = isSecurityEnclaveActive ? .systemGreen : .systemRed
  }

  @IBAction func biometryChanged(_ sender: Any) {
    statusLabel.text = "N/A"
  }

  @IBAction func TestSign(_ sender: Any) {
    if SecurityEnclaveManager.isSecureEnclaveAvailable() {
      print("Has security Enclave support")

      let data = "TEST Data".data(using: .utf8)!
      var result: Result<String, SecurityError>!

      if #available(iOS 13.0, *) {
        let keyTest = KeyTest_iOS13(isBiometryRequired: true)
        result = keyTest.testSecureEnclave(purpose: .signing, data: data)
      } else {
        let keyTest = KeyTest_iOS10(isBiometryRequired: true)
        result = keyTest.testSecureEnclave(purpose: .signing, data: data)
      }

      switch result {
      case let .success(signatureKeyHex):
        print("Success: \(signatureKeyHex)")

      case let .failure(error):
        print(error)

      case .none:
        print("none")
      }
    }
  }
}
