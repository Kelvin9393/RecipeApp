//
//  RecipeServices.swift
//  RecipeApp
//
//  Created by KELVIN LING SHENG SIANG on 28/04/2019.
//  Copyright © 2019 KELVIN LING SHENG SIANG. All rights reserved.
//

import Foundation
import SwiftyXMLParser
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class RecipeService {
    static let instance = RecipeService()
    
    var selectedRecipeType: RecipeType?
    
    var recipeTypes = [RecipeType]()
    var recipes = [Recipe]()
    
    func getRecipeType(completion: @escaping CompletionHandler) {
        if let path = Bundle.main.url(forResource: "recipetypes", withExtension: "xml") {
            let stringContent = try! String(contentsOf: path)
            let xml = try! XML.parse(stringContent)
            for recipeType in xml.recipeTypes.recipeType {
                guard let id = recipeType.attributes["id"], let name = recipeType["name"].text else { return }
                let recipeType = RecipeType(id: id, name: name)
                recipeTypes.append(recipeType)
            }
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func getRecipeList(forRecipeType recipeType: RecipeType, completion: @escaping CompletionHandler) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let fetchRequest = NSFetchRequest<Recipe>(entityName: "Recipe")
        let predicate = NSPredicate(format: "recipeTypeID == %@", recipeType.id)
        fetchRequest.predicate = predicate
        
        do {
            recipes = try managedContext.fetch(fetchRequest)
            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
}
