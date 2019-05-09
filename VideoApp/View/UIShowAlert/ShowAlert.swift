//
//  ShowAlert.swift
//  VideoApp
//
//  Created by NM Cường on 23/06/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//
import UIKit

extension UIViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle:.alert)
        // add actipn
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
