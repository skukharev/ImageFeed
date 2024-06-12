//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Сергей Кухарев on 18.05.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Private Properties

    /// Фото профиля
    private lazy var profilePhoto: UIImageView = {
        let profilePhoto = UIImageView()
        profilePhoto.image = UIImage(named: "ProfilePhoto") ?? UIImage()
        profilePhoto.translatesAutoresizingMaskIntoConstraints = false
        return profilePhoto
    }()

    /// Кнопка выхода из профиля
    private lazy var exitButton: UIButton = {
        let exitButton = UIButton(type: .system)
        exitButton.setImage(UIImage(named: "ExitButton"), for: .normal)
        exitButton.tintColor = .ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        return exitButton
    }()

    /// Имя пользователя
    private lazy var userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.textColor = .ypWhite
        userNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return userNameLabel
    }()

    /// Логин пользователя
    private lazy var userLoginLabel: UILabel = {
        let userLoginLabel = UILabel()
        userLoginLabel.textColor = .ypGray
        userLoginLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        userLoginLabel.text = "@ekaterina_nov"
        userLoginLabel.translatesAutoresizingMaskIntoConstraints = false
        return userLoginLabel
    }()

    /// Комментарии пользователя
    private lazy var userCommentsLabel: UILabel = {
        let userCommentsLabel = UILabel()
        userCommentsLabel.textColor = .ypWhite
        userCommentsLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        userCommentsLabel.text = "Hello, world!"
        userCommentsLabel.translatesAutoresizingMaskIntoConstraints = false
        return userCommentsLabel
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        setupConstraints()
    }

    // MARK: - Private Methods

    /// Создаёт элементы управления в контроллере профиля пользователя
    private func addSubviews() {
        view.addSubview(profilePhoto)
        view.addSubview(exitButton)
        view.addSubview(userNameLabel)
        view.addSubview(userLoginLabel)
        view.addSubview(userCommentsLabel)
    }

    /// Создаёт и размещает элементы управления в контроллере профиля пользователя
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Фото профиля
            profilePhoto.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profilePhoto.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            profilePhoto.widthAnchor.constraint(equalToConstant: 70),
            profilePhoto.heightAnchor.constraint(equalToConstant: 70),
            // Кнопка выхода из профиля
            exitButton.centerYAnchor.constraint(equalTo: profilePhoto.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            // Имя пользователя
            userNameLabel.topAnchor.constraint(equalTo: profilePhoto.bottomAnchor, constant: 8),
            userNameLabel.leftAnchor.constraint(equalTo: profilePhoto.leftAnchor),
            // Логин пользователя
            userLoginLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            userLoginLabel.leftAnchor.constraint(equalTo: profilePhoto.leftAnchor),
            // Комментарии пользователя
            userCommentsLabel.topAnchor.constraint(equalTo: userLoginLabel.bottomAnchor, constant: 8),
            userCommentsLabel.leftAnchor.constraint(equalTo: profilePhoto.leftAnchor)
        ])
    }
}
