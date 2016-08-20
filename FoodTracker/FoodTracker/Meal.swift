//
//  Meal.swift
//  FoodTracker
//
//  Created by Aniket Zamwar on 8/19/16.
//  Copyright © 2016 Aniket Zamwar. All rights reserved.
//

import UIKit

class Meal {
    
    // Mark: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    init?(name: String, photo: UIImage?, rating: Int) {
        self.name = name
        self.photo = photo
        self.rating = rating
        
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
}
