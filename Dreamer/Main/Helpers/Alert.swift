//
//  Alert.swift
//  Dreamer
//
//  Created by Justin Rose on 5/11/18.
//  Copyright © 2018 justncode LLC. All rights reserved.
//

import UIKit

struct Alert {
    static func controller(title: String, message: String, style: UIAlertControllerStyle, actions: [UIAlertAction]) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        _ = actions.map { action in
            alertController.addAction(action)
        }
        return alertController
    }
}
