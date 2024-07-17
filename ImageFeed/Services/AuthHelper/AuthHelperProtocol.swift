//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 17.07.2024.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}
