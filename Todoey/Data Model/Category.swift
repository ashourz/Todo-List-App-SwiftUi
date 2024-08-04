//
//  Category.swift
//  Todoey
//
//  Created by Zak Ashour on 7/2/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String? = nil
    let items = List<Item>()
}
