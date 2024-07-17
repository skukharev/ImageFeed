//
//  WebViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 17.07.2024.
//

import Foundation

protocol WebViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}
