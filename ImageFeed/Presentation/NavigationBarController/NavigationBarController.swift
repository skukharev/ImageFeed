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
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        self.viewControllers = [authViewController]
    }
}
