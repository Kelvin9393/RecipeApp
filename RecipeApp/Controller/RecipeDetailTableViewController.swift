//
//  RecipeDetailTableViewController.swift
//  RecipeApp
//
//  Created by KELVIN LING SHENG SIANG on 28/04/2019.
//  Copyright © 2019 KELVIN LING SHENG SIANG. All rights reserved.
//

import UIKit

class RecipeDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var recipeIV: UIImageView!
    @IBOutlet weak var recipeTypeTF: UITextField!
    @IBOutlet weak var recipeNameTF: UITextField!
    @IBOutlet weak var ingredientsTV: UITextView!
    @IBOutlet weak var stepsTV: UITextView!
    @IBOutlet weak var deleteBarBtnItem: UIBarButtonItem!
    @IBOutlet weak var saveBarBtnItem: UIBarButtonItem!
    
    var selectedRecipe: Recipe?
    private var isEditingRecipe = false
    private var selectedRecipeTypeID = RecipeService.instance.selectedRecipeType?.id
    private let recipeTypePV = UIPickerView()
    private let recipeTypeToolBar = UIToolbar()
    private let ingredientsToolBar = UIToolbar()
    private let stepsToolBar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    //    MARK: TableView functions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if isEditingRecipe || selectedRecipe == nil {
                pickImage()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return true
        } else {
            return false
        }
    }
    
    //    MARK: CoreData functions
    private func saveRecipe(completion: @escaping CompletionHandler) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        if let recipe = selectedRecipe {
            recipe.setValue(recipeNameTF.text, forKey: "name")
            recipe.setValue(ingredientsTV.text, forKey: "ingredients")
            recipe.setValue(stepsTV.text, forKey: "steps")
            recipe.setValue(selectedRecipeTypeID, forKey: "recipeTypeID")
            
            if let recipeImage = recipeIV.image?.fixImageOrientation() {
                if let imageData = recipeImage.pngData() {
                    recipe.setValue(NSData(data: imageData) as Data, forKey: "image")
                }
            }
        } else {
            let recipe = Recipe(context: managedContext)
            recipe.name = recipeNameTF.text
            recipe.ingredients = ingredientsTV.text
            recipe.steps = stepsTV.text
            recipe.recipeTypeID = selectedRecipeTypeID
            
            if let recipeImage = recipeIV.image?.fixImageOrientation() {
                if let imageData = recipeImage.pngData() {
                    recipe.image = NSData(data: imageData) as Data
                }
            }
        }
        
        do {
            try managedContext.save()
            print("Successfully saved")
            completion(true)
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func deleteRecipe(completion: @escaping CompletionHandler) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        if let recipe = selectedRecipe {
            managedContext.delete(recipe)
            
            do {
                try managedContext.save()
                print("Successfully deleted")
                completion(true)
            } catch {
                debugPrint("Could not delete: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    //    MARK: ImagePicker
    private func pickImage() {
        let imagePicker = UIImagePickerController()
        let photoAction = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePicker.delegate = self
        imagePicker.navigationBar.barStyle = .blackTranslucent
        imagePicker.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            photoAction.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            photoAction.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        photoAction.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoAction, animated: true, completion: nil)
    }
    
    //    MARK: IBActions functions
    @IBAction func savePressed(_ sender: Any) {
        if selectedRecipe == nil {
            saveRecipe { (success) in
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            if !isEditingRecipe {
                saveBarBtnItem.title = "Save"
                deleteBarBtnItem.title = "Delete"
                deleteBarBtnItem.isEnabled = true
            } else {
                saveRecipe { (success) in
                    if success {
                        self.saveBarBtnItem.title = "Edit"
                        self.deleteBarBtnItem.title = ""
                        self.deleteBarBtnItem.isEnabled = false
                    }
                }
            }
            isEditingRecipe = !isEditingRecipe
            toggleFields()
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        deleteRecipe { (success) in
            if success {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func recipeNameEditingChange(_ sender: Any) {
        if validateAllFields() {
            saveBarBtnItem.isEnabled = true
        } else {
            saveBarBtnItem.isEnabled = false
        }
    }
    
    //    MARK: UI configurations
    private func validateAllFields() -> Bool {
        var result = true
        if recipeTypeTF.text == "" || recipeNameTF.text == "" || ingredientsTV.text == "" || stepsTV.text == "" {
            result = false
        }
        return result
    }
    
    private func toggleFields() {
        if selectedRecipe != nil {
            if isEditingRecipe {
                recipeTypeTF.isEnabled = true
                recipeNameTF.isEnabled = true
                ingredientsTV.isEditable = true
                ingredientsTV.isUserInteractionEnabled = true
                stepsTV.isEditable = true
                stepsTV.isUserInteractionEnabled = true
            } else {
                recipeTypeTF.isEnabled = false
                recipeNameTF.isEnabled = false
                ingredientsTV.isEditable = false
                ingredientsTV.isUserInteractionEnabled = false
                stepsTV.isEditable = false
                stepsTV.isUserInteractionEnabled = false
            }
        } else {
            recipeTypeTF.isEnabled = true
            recipeNameTF.isEnabled = true
            ingredientsTV.isEditable = true
            ingredientsTV.isUserInteractionEnabled = true
            stepsTV.isEditable = true
            stepsTV.isUserInteractionEnabled = true
        }
    }
    
    //    MARK: OBJC functions
    @objc private func recipeTypeDonePressed() {
        let selectedRecipeType = RecipeService.instance.recipeTypes[recipeTypePV.selectedRow(inComponent: 0)]
        recipeTypeTF.text = selectedRecipeType.name
        self.selectedRecipeTypeID = selectedRecipeType.id
        recipeTypeTF.resignFirstResponder()
        recipeNameTF.becomeFirstResponder()
    }
    
    @objc private func ingredientsDonePressed() {
        ingredientsTV.resignFirstResponder()
        stepsTV.becomeFirstResponder()
    }
    
    @objc private func stepsDonePressed() {
        stepsTV.resignFirstResponder()
    }
    
    private func setupView() {
        if let recipe = selectedRecipe {
            title = "Recipe Details"
            deleteBarBtnItem.title = ""
            deleteBarBtnItem.isEnabled = false
            saveBarBtnItem.title = "Edit"
            saveBarBtnItem.isEnabled = true
            
            if let recipeImageData = recipe.image {
                recipeIV.image = UIImage(data: recipeImageData as Data)
            }
            recipeNameTF.text = recipe.name
            ingredientsTV.text = recipe.ingredients
            stepsTV.text = recipe.steps
        } else {
            title = "Add New Recipe"
            deleteBarBtnItem.title = ""
            deleteBarBtnItem.isEnabled = false
            saveBarBtnItem.title = "Save"
            saveBarBtnItem.isEnabled = false
        }
        
        toggleFields()
        
        recipeTypePV.delegate = self
        recipeTypePV.dataSource = self
        
        let spacingArea = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let recipeTypeDoneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(recipeTypeDonePressed))
        recipeTypeToolBar.setItems([spacingArea, recipeTypeDoneBtn], animated: false)
        recipeTypeToolBar.isUserInteractionEnabled = true
        recipeTypeToolBar.barStyle = .default
        recipeTypeToolBar.isTranslucent = true
        recipeTypeToolBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 1, alpha: 1)
        recipeTypeToolBar.sizeToFit()
        
        recipeTypeTF.text = RecipeService.instance.selectedRecipeType?.name
        recipeTypeTF.inputView = recipeTypePV
        recipeTypeTF.inputAccessoryView = recipeTypeToolBar
        
        recipeNameTF.autocapitalizationType = .words
        recipeNameTF.delegate = self
        
        let ingredientsDoneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(ingredientsDonePressed))
        ingredientsToolBar.setItems([spacingArea, ingredientsDoneBtn], animated: false)
        ingredientsToolBar.isUserInteractionEnabled = true
        ingredientsToolBar.barStyle = .default
        ingredientsToolBar.isTranslucent = true
        ingredientsToolBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 1, alpha: 1)
        ingredientsToolBar.sizeToFit()
        
        ingredientsTV.delegate = self
        ingredientsTV.inputAccessoryView = ingredientsToolBar
        ingredientsTV.isScrollEnabled = false
        ingredientsTV.layer.borderWidth = 0.5
        ingredientsTV.layer.borderColor = UITableView().separatorColor?.cgColor
        ingredientsTV.layer.cornerRadius = 5
        
        let stepsDoneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(stepsDonePressed))
        stepsToolBar.setItems([spacingArea, stepsDoneBtn], animated: false)
        stepsToolBar.isUserInteractionEnabled = true
        stepsToolBar.barStyle = .default
        stepsToolBar.isTranslucent = true
        stepsToolBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 1, alpha: 1)
        stepsToolBar.sizeToFit()
        
        stepsTV.delegate = self
        stepsTV.inputAccessoryView = stepsToolBar
        stepsTV.isScrollEnabled = false
        stepsTV.layer.borderWidth = 0.5
        stepsTV.layer.borderColor = UITableView().separatorColor?.cgColor
        stepsTV.layer.cornerRadius = 5
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
    }
    
}

extension RecipeDetailTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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

extension RecipeDetailTableViewController: UITextViewDelegate, UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case recipeTypeTF:
            recipeNameTF.becomeFirstResponder()
        default:
            ingredientsTV.becomeFirstResponder()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if validateAllFields() {
            saveBarBtnItem.isEnabled = true
        } else {
            saveBarBtnItem.isEnabled = false
        }
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize.init(width: size.width, height: .greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if textView == ingredientTV {
//            if (text == "\n") {
//                if range.location == textView.text.count {
//                    let updatedText: String = textView.text!.appendingFormat("\n \u{2022} ")
//                    textView.text = updatedText
//                }
//                else {
//                    let beginning: UITextPosition = textView.beginningOfDocument
//                    let start = textView.position(from: beginning, offset: range.location)!
//                    let end = textView.position(from: start, offset: range.length)!
//                    let textRange = textView.textRange(from: start, to: end)!
//                    textView.replace(textRange, withText: "\n \u{2022} ")
//                    let cursor: NSRange = NSMakeRange(range.location + "\n \u{2022} ".count, 0)
//                    textView.selectedRange = cursor
//                }
//                return false
//            }
//        } else {
//            if (stepsTV.text.isEmpty && !text.isEmpty) {
//                stepsTV.text = "\(currentStep)"
//                currentStep += 1
//            } else {
//                if text.isEmpty {
//                    if stepsTV.text.count >= 4 {
//                        let str = String(text[textView.text.index(textView.text.endIndex, offsetBy: -4)...])
//                        if str.hasPrefix("\n") {
//                            textView.text = String(textView.text.dropLast(3))
//                            currentStep -= 1
//                        }
//                    }
//                    else if text.isEmpty && textView.text.count == 3 {
//                        textView.text = String(textView.text.dropLast(3))
//                        currentStep = 1
//                    }
//                }
//                else {
//                    let str = String(text[textView.text.index(textView.text.endIndex, offsetBy: -1)...])
//                    if str == "\n" {
//                        textView.text = "\(textView.text!)\(currentStep). "
//                        currentStep += 1
//                    }
//                }
//            }
//        }
//        return true
//    }
}

extension RecipeDetailTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            recipeIV.image = selectedImage
        }
        dismiss(animated: true)
    }
}
