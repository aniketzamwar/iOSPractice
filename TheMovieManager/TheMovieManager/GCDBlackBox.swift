//
//  GCDBlackBox.swift
//  FlickFinder
//
//  Created by Aniket Zamwar on 8/11/16.
//  Copyright © 2015 Udacity. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
