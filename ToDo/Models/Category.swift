//
//  Category.swift
//  ToDo
//
//  Created by Erik Ugarte on 2020-09-25.
//  Copyright © 2020 Creative League. All rights reserved.
//

import Foundation
import Firebase

class Category {
    
    // MARK: Variables
    var name : String
    var tasks : [String]
    
    // MARK: initializers
    init(name: String, tasks: [String]) {
        self.name = name
        self.tasks = tasks
    }
}
