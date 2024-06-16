//
//  ProfileViewPresenterDelegate.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 16.06.2024.
//

import Foundation

protocol ProfileViewPresenterDelegate: AnyObject {
    func showUserData(userProfile: UnsplashCurrentUserProfile)
    func showLoadingProfileError(withError: Error)
}
