//
//  SnakeCaseJSONDecoder.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 12.06.2024.
//

import Foundation

/// Вспомогательный класс для автоматического приведения обрабатываемых JSON из SnakeCase к виду camelCase
final class SnakeCaseJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
