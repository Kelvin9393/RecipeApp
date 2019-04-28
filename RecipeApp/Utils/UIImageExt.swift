//
//  UIImageExt.swift
//  RecipeApp
//
//  Created by KELVIN LING SHENG SIANG on 29/04/2019.
//  Copyright © 2019 KELVIN LING SHENG SIANG. All rights reserved.
//

import UIKit

extension UIImage {
    func fixImageOrientation() -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
