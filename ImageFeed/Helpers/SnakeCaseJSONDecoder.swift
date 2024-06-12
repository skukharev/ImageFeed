//
//  SnakeCaseJSONDecoder.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 12.06.2024.
//

import Foundation

class SnakeCaseJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
