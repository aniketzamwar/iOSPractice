//
//  GenreTableViewController.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - GenreTableViewController: UITableViewController

class GenreTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var movies: [Movie] = [Movie]()
    var genreID: Int? = nil
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // get the correct genre id
        genreID = genreIDFromItemTag(tabBarItem.tag)
        
        // create and set logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        /* TASK: Get movies by a genre id, then populate the table */
        
        /* 1. Set the parameters */
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/genre/\(genreID!)/movies"))
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTask(with: request as URLRequest) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did TheMovieDB return an error? */
            if let _ = parsedResult[Constants.TMDBResponseKeys.StatusCode] as? Int {
                print("TheMovieDB returned an error. See the '\(Constants.TMDBResponseKeys.StatusCode)' and '\(Constants.TMDBResponseKeys.StatusMessage)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "results" key in parsedResult? */
            guard let results = parsedResult[Constants.TMDBResponseKeys.Results] as? [[String:AnyObject]] else {
                print("Cannot find key '\(Constants.TMDBResponseKeys.Results)' in \(parsedResult)")
                return
            }
            
            /* 6. Use the data! */
            self.movies = Movie.moviesFromResults(results)
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    // MARK: Logout
    
    func logout() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - GenreTableViewController (UITableViewController)

extension GenreTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell type
        let cellReuseIdentifier = "MovieTableViewCell"
        let movie = movies[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set cell defaults
        cell?.textLabel!.text = movie.title
        cell?.imageView!.image = UIImage(named: "Film Icon")
        cell?.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        
        /* TASK: Get the poster image, then populate the image view */
        if let posterPath = movie.posterPath {
            
            /* 1. Set the parameters */
            // There are none...
            
            /* 2. Build the URL */
            let baseURL = URL(string: appDelegate.config.baseImageURLString)!
            let url = baseURL.appendingPathComponent("w154").appendingPathComponent(posterPath)
            
            /* 3. Configure the request */
            let request = URLRequest(url: url)
            
            /* 4. Make the request */
            let task = appDelegate.sharedSession.dataTask(with: request) { (data, response, error) in
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    print("There was an error with your request: \(error)")
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                    print("Your request returned a status code other than 2xx!")
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    print("No data was returned by the request!")
                    return
                }
                
                /* 5. Parse the data */
                // No need, the data is already raw image data.
                
                /* 6. Use the data! */
                if let image = UIImage(data: data) {
                    performUIUpdatesOnMain {
                        cell?.imageView!.image = image
                    }
                } else {
                    print("Could not create image from \(data)")
                }
            }
            
            /* 7. Start the request */
            task.resume()
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // push the movie detail view
        let controller = storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        controller.movie = movies[(indexPath as NSIndexPath).row]
        navigationController!.pushViewController(controller, animated: true)
    }
    
    
}

// MARK: - GenreTableViewController (Genre Map)

extension GenreTableViewController {
    
    private func genreIDFromItemTag(_ itemTag: Int) -> Int {
        
        let genres: [String] = [
            "Sci-Fi",
            "Comedy",
            "Action"
        ]
        
        let genreMap: [String:Int] = [
            "Action": 28,
            "Sci-Fi": 878,
            "Comedy": 35
        ]
        
        return genreMap[genres[itemTag]]!
    }    
}
