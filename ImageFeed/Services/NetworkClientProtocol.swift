//
//  NetworkClientProtocol.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 10.06.2024.
//

import Foundation

protocol NetworkClientProtocol {
    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
}
