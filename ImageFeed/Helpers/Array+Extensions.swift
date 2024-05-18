//
//  Array+Extensions.swift
//
//  Created by Сергей Кухарев on 02.04.2024.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
