//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Zak Ashour on 6/26/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    let categoryListKey = "CategoryArray"
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Categories.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadCategories()
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        if let color = UIColor(hexString: "1D9BF6"){
            navBar.backgroundColor = color
            navBar.barTintColor = color
            
//            navBar.tintColor = ContrastColorOf(color, returnFlat: true)
//            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
            navBar.tintColor = UIColor.black
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
    }

    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let category = categoryArray?[indexPath.row]
        cell.textLabel?.text = category?.name ?? "No Categories Added Yet"
        if let categoryColor = category?.color {
            if let color = UIColor(hexString: categoryColor){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }

        } else {
            let uiColor = UIColor.randomFlat()
            cell.backgroundColor = uiColor
            cell.textLabel?.textColor = ContrastColorOf(uiColor, returnFlat: true)

            if(category != nil){
                category!.color = uiColor.hexValue()
                updateColor(index: indexPath.row, colorHex: uiColor.hexValue())

            }
        }
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(categoryArray?[indexPath.row] ?? "Nothing Selected")
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    
    //MARK: - Add New Category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add Category", style: .default){ (action) in
            if let userText = textField.text{
                let newCategory = Category()
                newCategory.name = userText
                newCategory.color = UIColor.randomFlat().hexValue()
                self.save(category: newCategory)
                
            }
        }
        
        alert.addAction(action)
        alert.addTextField(){ (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    

    
    //MARK: - Tableview Manipulation Methods
   
    

    func save(category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
        
    }
    
    func loadCategories(){
        categoryArray = realm.objects(Category.self)
        
        self.tableView.reloadData()
    }
    
    override func deleteItem(index: Int){
        super.deleteItem(index: index)
        do{
            try realm.write{
                if let category = categoryArray?[index]{
                    realm.delete(category)
                }
            }
        }catch{
            print("Error deleting category \(error)")
        }
    }
    
    func updateColor(index: Int, colorHex: String){
        super.deleteItem(index: index)
        do{
            try self.realm.write {
                if let category = categoryArray?[index]{
                    category.color = colorHex
                }
            }
        }catch{
            print("Error saving new tiems, \(error)")
        }
    }
    
}

