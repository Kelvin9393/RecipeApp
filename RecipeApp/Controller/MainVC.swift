//
//  ViewController.swift
//  RecipeApp
//
//  Created by KELVIN LING SHENG SIANG on 28/04/2019.
//  Copyright © 2019 KELVIN LING SHENG SIANG. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var recipeTypeTF: UITextField!
    @IBOutlet weak var viewRecipesBtn: UIButton!
    
    private let recipeTypePV = UIPickerView()
    private let toolBar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func donePressed() {
        let selectedRecipeType = RecipeService.instance.recipeTypes[recipeTypePV.selectedRow(inComponent: 0)]
        recipeTypeTF.text = selectedRecipeType.name
        RecipeService.instance.selectedRecipeType = selectedRecipeType
        recipeTypeTF.resignFirstResponder()
        viewRecipesBtn.isEnabled = true
    }
    
    @IBAction func viewRecipesPressed(_ sender: Any) {
        guard let customNavigationController = storyboard?.instantiateViewController(withIdentifier: "CustomNavigationController") as? CustomNavigationController else { return }
        
        UIApplication.shared.keyWindow?.switchRootViewController(customNavigationController, animated: true, duration: 0.4, options: .transitionFlipFromRight, completion: nil)
    }
    
    private func setupView() {
        RecipeService.instance.getRecipeType { (success) in
            self.recipeTypePV.reloadAllComponents()
        }
        
        recipeTypePV.delegate = self
        recipeTypePV.dataSource = self
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil
            , action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 1, alpha: 1)
        toolBar.sizeToFit()
        
        recipeTypeTF.attributedPlaceholder = NSAttributedString(string: "Select a recipe type", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8232288099, green: 0.1491314173, blue: 0, alpha: 1)])
        recipeTypeTF.inputView = recipeTypePV
        recipeTypeTF.inputAccessoryView = toolBar
    }
}

extension MainVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RecipeService.instance.recipeTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return RecipeService.instance.recipeTypes[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRecipeType = RecipeService.instance.recipeTypes[row]
        recipeTypeTF.text = selectedRecipeType.name
    }
}

