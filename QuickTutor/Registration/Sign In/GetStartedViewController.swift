//
//  GetStartedViewController.swift
//  QuickTutor
//
//  Created by Roberto Garrido on 17/06/2019.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class GetStartedViewController: UIViewController {
    
    let nextButton: DimmableButton = {
        let button = DimmableButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.purple
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.setTitle("GET STARTED", for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let quickTutorLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo + R(s)"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "img_walkthrough_bg"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override func loadView() {
        view = UIView()
        
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        
        view.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            nextButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
            nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        nextButton.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
        
        view.addSubview(quickTutorLogo)
        NSLayoutConstraint.activate([
            quickTutorLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quickTutorLogo.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            quickTutorLogo.heightAnchor.constraint(equalToConstant: 35)
            ])
    }
    
    @objc func handleButton(_ sender: UIButton) {
        navigationController?.pushViewController(SignInVC(), animated: true)
    }
}
