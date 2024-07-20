//
//  Constants.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 09.06.2024.
//

import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let defaultBaseURL: URL?
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authURLString = authURLString
        self.defaultBaseURLString = defaultBaseURLString
        self.defaultBaseURL = URL(string: defaultBaseURLString)
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey, secretKey: Constants.secretKey, redirectURI: Constants.redirectURI, accessScope: Constants.accessScope, authURLString: Constants.unsplashAuthorizeURLString, defaultBaseURLString: Constants.defaultBaseURLString)
    }
}
