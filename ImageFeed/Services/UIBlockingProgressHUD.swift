//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 16.06.2024.
//

import UIKit
import ProgressHUD

/// Сервис по блокированию UI на момент отображения индикатора загрузки
enum UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    /// Отображает индикатор загрузки, блокирует UI
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }

    /// Скрывает индикатор загрузки, разблокирует UI
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
