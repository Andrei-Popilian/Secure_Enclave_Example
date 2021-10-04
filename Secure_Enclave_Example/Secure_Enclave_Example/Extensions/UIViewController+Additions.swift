//
//  UIViewController.swift
//  Secure_Enclave_Example
//
//  Created by Popilian Andrei on 10/1/21.
//

import UIKit

extension UIAlertController {
  static func show(title: String?, text: String?, from vc: UIViewController) {
    let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    vc.present(alert, animated: true)
  }
}
