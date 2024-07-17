//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 17.07.2024.
//

import Foundation

protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}
