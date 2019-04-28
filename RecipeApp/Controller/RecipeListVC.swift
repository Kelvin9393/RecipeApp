//
//  RecipeListVC.swift
//  RecipeApp
//
//  Created by KELVIN LING SHENG SIANG on 28/04/2019.
//  Copyright © 2019 KELVIN LING SHENG SIANG. All rights reserved.
//

import UIKit

class RecipeListVC: UIViewController {
    
    @IBOutlet weak var recipeTypeTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private let recipeTypePV = UIPickerView()
    private let toolBar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRecipeList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController = segue.destination as! RecipeDetailTableViewController
        if segue.identifier == "ShowRecipe" {
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                destinationController.selectedRecipe = RecipeService.instance.recipes[indexPath.row]
            }
        }
    }
    
    @objc private func donePressed() {
        let selectedRecipeType = RecipeService.instance.recipeTypes[recipeTypePV.selectedRow(inComponent: 0)]
        recipeTypeTF.text = selectedRecipeType.name
        RecipeService.instance.selectedRecipeType = selectedRecipeType
        recipeTypeTF.resignFirstResponder()
        getRecipeList()
    }

    private func setupView() {
        recipeTypeTF.text = RecipeService.instance.selectedRecipeType?.name
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 82
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
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
        
        recipeTypeTF.inputView = recipeTypePV
        recipeTypeTF.inputAccessoryView = toolBar
    }
    
    private func getRecipeList() {
        RecipeService.instance.getRecipeList(forRecipeType: RecipeService.instance.selectedRecipeType!) { (success) in
            self.tableView.reloadData()
        }
    }
}

extension RecipeListVC: UIPickerViewDelegate, UIPickerViewDataSource {
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

extension RecipeListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecipeService.instance.recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as? RecipeCell {
            let recipe = RecipeService.instance.recipes[indexPath.row]
            cell.configureCell(recipe: recipe)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
}
