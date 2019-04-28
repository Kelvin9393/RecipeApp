//
//  CustomNavigationController.swift
//  RecipeApp
//
//  Created by KELVIN LING SHENG SIANG on 28/04/2019.
//  Copyright © 2019 KELVIN LING SHENG SIANG. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    private func setupView() {
        self.delegate = self
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = #colorLiteral(red: 0.8232288099, green: 0.1491314173, blue: 0, alpha: 1)
        navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), NSAttributedString.Key.font: UIFont(name: "Avenir-heavy", size: 17) as Any]
    }


}
