//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 16.06.2024.
//

import UIKit
import ProgressHUD

enum UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }

    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
