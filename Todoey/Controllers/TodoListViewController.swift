//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var selectedCategory: Category? {
        didSet{
            loadRequestItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            title = selectedCategory!.name
            
            if let color = UIColor(hexString: colorHex){
                guard let navBar = navigationController?.navigationBar else {
                    fatalError("Navigation controller does not exist")
                }
                navBar.barTintColor = color
                navBar.backgroundColor = color
                navBar.tintColor = ContrastColorOf(color, returnFlat: true)
                let textAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
                navBar.largeTitleTextAttributes = textAttributes
                searchBar.barTintColor = color
                searchBar.tintColor = ContrastColorOf(color, returnFlat: true)
                searchBar.searchTextField.textColor = ContrastColorOf(color, returnFlat: true)
            }

        }
        
    }
    
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if todoItems != nil{
                if let categoryColor = selectedCategory?.color{
                    if let gradientColor = UIColor(hexString: categoryColor)?.darken(byPercentage:(CGFloat(indexPath.row)/CGFloat(todoItems!.count))){
                        cell.backgroundColor = gradientColor
                        cell.textLabel?.textColor = ContrastColorOf(gradientColor, returnFlat: true)
                    }
                }
            }
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status, \(error)")
            }
            
        }
        self.tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add Item", style: .default){ (action) in
            if let userText = textField.text{
                if let currentCategory = self.selectedCategory{
                    do{
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = userText
                            currentCategory.items.append(newItem)
                        }
                    }catch{
                        print("Error saving new tiems, \(error)")
                    }
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        alert.addTextField(){ (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manipulation
    
    func loadRequestItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        if (selectedCategory?.name) != nil {
            self.tableView.reloadData()
        }
    }
    
    
    override func deleteItem(index: Int){
        super.deleteItem(index: index)
        do{
            try realm.write {
                if let item = todoItems?[index]{
                    realm.delete(item)
                }
            }
        }catch{
            print("Error deleting item, \(error)")
        }
    }
}

//MARK: - Search bar method
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button pressed")
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text{
            print("Search field updated to: \(searchText)")
            
            if searchText.isEmpty {
                loadRequestItems()
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            }
        }
    }
}

