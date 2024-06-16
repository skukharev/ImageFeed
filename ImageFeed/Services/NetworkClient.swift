//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 10.06.2024.
//

import Foundation

final class NetworkClient: NetworkClientProtocol {
    // MARK: - Private Properties

    private enum NetworkError: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
    }

    private var urlSessionDataTask: URLSessionDataTask?

    // MARK: - Public Methods

    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        if urlSessionDataTask != nil {
            urlSessionDataTask?.cancel()
            urlSessionDataTask = nil
        }

        urlSessionDataTask = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            self?.urlSessionDataTask = nil

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
        urlSessionDataTask?.resume()
    }
}
