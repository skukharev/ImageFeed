//
//  ProfileViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 11.07.2024.
//

import Foundation
import UIKit

protocol ProfileViewControllerDelegate: AnyObject {
    /// Обработчик события выхода из профиля пользователя
    func didProfileLogout(_ viewController: UIViewController?)
}
