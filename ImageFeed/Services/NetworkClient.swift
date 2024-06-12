//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 10.06.2024.
//

import Foundation

struct NetworkClient: NetworkClientProtocol {
    // MARK: - Private Properties

    private enum NetworkError: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
    }

    // MARK: - Public Methods

    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(NetworkError.urlRequestError(error)))
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            guard let data = data else {
                handler(.failure(NetworkError.urlSessionError))
                return
            }
            handler(.success(data))
        }
        task.resume()
    }
}
