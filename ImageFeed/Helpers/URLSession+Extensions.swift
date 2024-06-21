//
//  URLSession+Extensions.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 21.06.2024.
//

import Foundation

enum URLSessionError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case dataConversionError
}

extension URLSessionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .httpStatusCode(let code):
            return NSLocalizedString("httpStatusCode, код ошибки: \(code)", comment: "URLSessionError")
        case .urlRequestError(let error):
            return NSLocalizedString("urlRequestErrork: \(error.localizedDescription)", comment: "URLSessionError")
        case .urlSessionError:
            return NSLocalizedString("urlSessionError", comment: "URLSessionError")
        case .dataConversionError:
            return NSLocalizedString("dataConversionError", comment: "URLSessionError")
        }
    }
}

extension URLSession {
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print(#fileID, #function, #line, "[\(URLSessionError.httpStatusCode(statusCode).localizedDescription)]")
                    fulfillCompletionOnTheMainThread(.failure(URLSessionError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print(#fileID, #function, #line, "[\(URLSessionError.urlRequestError(error).localizedDescription)]")
                fulfillCompletionOnTheMainThread(.failure(URLSessionError.urlRequestError(error)))
            } else {
                print(#fileID, #function, #line, "[\(URLSessionError.urlSessionError.localizedDescription)]")
                fulfillCompletionOnTheMainThread(.failure(URLSessionError.urlSessionError))
            }
        }

        return task
    }

    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let objectTaskData = try SnakeCaseJSONDecoder().decode(T.self, from: data)
                    completion(.success(objectTaskData))
                } catch {
                    DispatchQueue.main.async {
                        print(#fileID, #function, #line, "Ошибка декодирования: \(error.localizedDescription), данные: \(String(decoding: data, as: UTF8.self))")
                        completion(.failure(URLSessionError.dataConversionError))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
