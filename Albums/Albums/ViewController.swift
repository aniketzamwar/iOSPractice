//
//  ViewController.swift
//  Albums
//
//  Created by Aniket Zamwar on 8/1/16.
//  Copyright © 2016 Aniket Zamwar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    // ToDo: Replace the hostname
    let firebase = FirebaseApp(hostname: "*.firebaseio.com")
    var albums: [Album] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func reloadData() {
        firebase.fetchAlbums {
            (albums, error) in
            if let error = error {
                self.showAlert(error: error)
            } else {
                if let albums = albums {
                    self.albums = albums
                    self.albums.sort()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func showAlert(error: NSError) {
        let alert = UIAlertView(
            title: "Oops!",
            message: "Could not fetch albums data.",
            delegate: nil,
            cancelButtonTitle: "OK")
        
        alert.show()
    }
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell") as UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "AlbumCell")
        }
        cell!.textLabel?.text = albums[indexPath.row].description
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            let album = albums[indexPath.row]
            firebase.deleteAlbum(album: album, completionHandler: { (error) in
                if let error = error {
                    self.showAlert(error: error)
                } else {
                    self.albums.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Add album
    
    @IBAction func cancel(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func add(segue: UIStoryboardSegue) {
        let detailController = segue.sourceViewController as! AddAlbumController
        firebase.saveAlbum(album: detailController.album) { (albumID, error) in
            if let err = error {
                self.showAlert(error: err)
            } else {
                self.reloadData()
            }
        }
        dismiss(animated: true, completion: nil)
    }

}

