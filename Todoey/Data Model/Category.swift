//
//  Category.swift
//  Todoey
//
//  Created by Jay Packer on 4/4/18.
//  Copyright © 2018 Jay Packer. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var categoryBGColor: String = "FFFFFF"
    
    let items = List<Item>()
    
    //Above syntax is similar to the following empty array of numbers.
    //let numbers = Array<Int>()
    
}
