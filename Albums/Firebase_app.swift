//
//  Firebase.swift
//  Albums
//
//  Created by Aniket Zamwar on 8/2/16.
//  Copyright © 2016 Aniket Zamwar. All rights reserved.
//

import Foundation

typealias FirebaseSaveCompletion = (String?, NSError?) -> Void
typealias FirebaseFetchCompletion = ([Album]?, NSError?) -> Void
typealias FirebaseDeleteCompletion = (NSError?) -> Void

class FirebaseApp {
    let hostname: String
    var albumsURL: NSURL {
        return NSURL(scheme: "https", host: hostname, path: "/albums.json")!
    }
    
    init(hostname: String) {
        self.hostname = hostname
    }
    
    func fetchAlbums(completionHandler: FirebaseFetchCompletion) {
        var request = NSURLRequest(url: albumsURL as URL)
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.current!) {
            (response, data, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            do {
                
                let json: AnyObject? = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
        
                if let json: AnyObject = json {
                    if let json = json as? [String: AnyObject] {
                        var albums: [Album] = []
                        for (key, item) in json {
                            if let item = item as? [String: String] {
                                var album = Album(band: item["band"]! , title: item["title"]!)
                                album.id = key
                                albums.append(album)
                            }
                        }
                        completionHandler(albums, nil)
                        return
                    }
                    completionHandler(nil, NSError(domain: "albums", code: 100, userInfo: nil))
                    return
                } else {
                    completionHandler(nil, NSError(domain: "albums", code: 101, userInfo: nil))
                    return
                }
            } catch let error as NSError {
                    completionHandler(nil, error)
                    return
                }
        }
    }
    
    func saveAlbum(album: Album, completionHandler: FirebaseSaveCompletion) {
        
        var request = NSMutableURLRequest(url: albumsURL as URL)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: album.toJSON(), options: [])
            
        } catch let error as NSError {
            completionHandler(nil, error)
            return
        }
        print("CHECK")
        print(request.httpBody)
        print(request.allHTTPHeaderFields)
        
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.current!) {
            (response, data, error) in
            print(response)
            if let error = error {
                print(error)
                completionHandler(nil, error)
                return
            }
            
            do {
                let obj: AnyObject? = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                if let obj: AnyObject = obj {
                    if let albumDict = obj as? [String: String] {
                        let albumID = albumDict["name"]
                        completionHandler(albumID, nil)
                    }
                } else {
                    completionHandler(nil, NSError(domain: "albums", code: 102, userInfo: nil))
                    return
                }
                
            } catch let error as NSError {
                print(error)
                completionHandler(nil, error)
                return
            }
        }
    }
    
    func deleteAlbum(album: Album, completionHandler: FirebaseDeleteCompletion) {
        if album.id == nil {
            completionHandler(NSError(domain: "albums", code: 103, userInfo: nil))
            return
        }
        
        let deleteURL = NSURL(scheme: "https", host: hostname, path: "/albums/\(album.id!).json")!
        let request = NSMutableURLRequest(url: deleteURL as URL)
        request.httpMethod = "DELETE"
        
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.current!) {
            (response, data, error) in
            if let error = error {
                completionHandler(error)
                return
            } else {
                completionHandler(nil)
                return
            }
        }
    }
    
}
