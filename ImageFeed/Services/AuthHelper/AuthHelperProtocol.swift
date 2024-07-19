//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 17.07.2024.
//

import Foundation

protocol AuthHelperProtocol {
    /// Формирует авторизационный запрос к сервису Unsplash
    /// - Returns: Возвращает сформированный запрос, сформированный в соответствии с п.п. 1 https://unsplash.com/documentation/user-authentication-workflow
    func authRequest() -> URLRequest?
    /// Анализирует ответ от Unsplash на авторизационный запрос, сформированный authRequest(), и возвращает код авторизации при успешной авторизации пользователя
    /// - Parameter url: ответ от Unsplash в соответствии с п.п. 2 https://unsplash.com/documentation/user-authentication-workflow
    /// - Returns: Возвращает код авторизации при успешной авторизации и nil в противном случае
    func code(from url: URL) -> String?
}
