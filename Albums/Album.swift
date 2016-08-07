//
//  Album.swift
//  Albums
//
//  Created by Aniket Zamwar on 8/1/16.
//  Copyright © 2016 Aniket Zamwar. All rights reserved.
//

import Foundation

class Album: Comparable {
    let band: String
    let title: String
    var id: String? = nil
    
    var description: String {
        return "\(band): \(title)"
    }
    
    init(band: String, title: String) {
        self.band = band
        self.title = title
    }
    
    func toJSON() -> [String: String] {
        return ["band": band, "title": title]
    }
}

func <(left: Album, right: Album) -> Bool {
    if left.band == right.band {
        return left.title < right.title
    }
    return left.band < right.band
}

func ==(left: Album, right: Album) -> Bool {
    if left.band == right.band {
        return left.title == right.title
    }
    return false
}
