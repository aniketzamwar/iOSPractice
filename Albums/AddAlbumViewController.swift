//
//  AddAlbumViewController.swift
//  Albums
//
//  Created by Aniket Zamwar on 8/1/16.
//  Copyright © 2016 Aniket Zamwar. All rights reserved.
//

import UIKit

class AddAlbumController: UITableViewController {
    @IBOutlet weak var albumTitleField: UITextField!
    @IBOutlet weak var bandField: UITextField!
    
    var album: Album!
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SaveAlbum" {
            album = Album(band: bandField.text!, title: albumTitleField.text!)
        }
    }
}
