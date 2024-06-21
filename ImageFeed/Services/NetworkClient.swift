//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 10.06.2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case dataConversionError
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .httpStatusCode(let code):
            return NSLocalizedString("httpStatusCode, код ошибки: \(code)", comment: "NetworkError")
        case .urlRequestError(let error):
            return NSLocalizedString("urlRequestErrork: \(error.localizedDescription)", comment: "NetworkError")
        case .urlSessionError:
            return NSLocalizedString("urlSessionError", comment: "NetworkError")
        case .dataConversionError:
            return NSLocalizedString("dataConversionError", comment: "NetworkError")
        }
    }
}

final class NetworkClient: NetworkClientProtocol {
    // MARK: - Private Properties

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
                print(#fileID, #function, #line, "[\(NetworkError.urlRequestError(error).localizedDescription)]")
                handler(.failure(NetworkError.urlRequestError(error)))
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                print(#fileID, #function, #line, "[\(NetworkError.httpStatusCode(response.statusCode).localizedDescription)]")
                handler(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            guard let data = data else {
                print(#fileID, #function, #line, "[\(NetworkError.urlSessionError.localizedDescription)]")
                handler(.failure(NetworkError.urlSessionError))
                return
            }
            handler(.success(data))
        }
        urlSessionDataTask?.resume()
    }

    func objectFetch<T: Decodable>(request: URLRequest, handler: @escaping (Result<T, Error>) -> Void) {
        fetch(request: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let objectData = try SnakeCaseJSONDecoder().decode(T.self, from: data)
                    handler(.success(objectData))
                } catch {
                    print(#fileID, #function, #line, "Ошибка декодирования: \(error.localizedDescription), данные: \(String(decoding: data, as: UTF8.self)))")
                    handler(.failure(NetworkError.dataConversionError))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
