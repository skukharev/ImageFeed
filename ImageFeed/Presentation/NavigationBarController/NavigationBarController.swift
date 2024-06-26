//
//  NavigationBarController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 23.06.2024.
//

import UIKit

final class NavigationBarController: UINavigationController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let authViewController = AuthViewController()
        self.viewControllers = [authViewController]
    }
}
