//
//  MyWhatsit.swift
//  MyStuff
//
//  Created by Aniket Zamwar on 11/23/15.
//  Copyright © 2015 Aniket Zamwar. All rights reserved.
//

import Foundation
import UIKit

let WhatsitDidChangeNotification = "MyWhatsitDidChange"

class MyWhatsit{
    
    var name: String {
        didSet {
            postDidChangeNotification()
        }
    }
    
    var location: String {
        didSet {
            postDidChangeNotification()
        }
    }
    
    var image: UIImage? {
        didSet {
            postDidChangeNotification()
        }
    }
    
    var viewImage: UIImage {
        return image ?? UIImage(named: "camera")!
    }
    
    init (name : String, location : String = "") {
        self.name = name;
        self.location = location;
    }
    
    func postDidChangeNotification() {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(WhatsitDidChangeNotification, object: self)
    }
    
}