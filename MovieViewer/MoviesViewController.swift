//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Vicky Guan on 1/9/17.
//  Copyright © 2017 Vicky Guan. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UITableView!
    
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]!    // Filtered movie titles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        // Display HUD right before the request is made
        // Loading status icon
        MBProgressHUD.showAdded(to: self.view, animated: true)
        print("Loading start!")
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // Hide HUD once the network request comes back (must be done on main UI thread)
    
            MBProgressHUD.hide(for: self.view, animated: true)
            print("Loading end!")
            
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.filteredData = self.movies
                    
                    self.tableView.reloadData()
                }
            }
        }
        
        searchBar.delegate = self
        filteredData = movies
        
        task.resume()
        
        // Initializing a refresh icon
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let filteredData = filteredData {
            return filteredData.count
        } else {
            return 0
        }
        /*if let movies = movies {
            return movies.count
        } else {
            return 0
        }*/
    }
    
    /* Displays movie poster, movie name, and movie description
       Also in part of imeplementing search bar functionality.
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = filteredData![indexPath.row]
        let title = movie["title"] as! String
        
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        
        let baseUrl = "https://image.tmdb.org/t/p/w342"

        let imageUrl = URL(string: baseUrl + posterPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWith(imageUrl!)
        
        print("row \(indexPath.row)")

        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? movies : movies?.filter({ (movie: NSDictionary) -> Bool in
            
            return (movie["title"] as? String)?.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        tableView.reloadData()
    }
    
    // This method updates filteredData based on the text in the Search Box
    /*func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("I HAVE ENTERED THE SEARCHBAR")
        if searchText.isEmpty {
            print("did not enter else")
            filteredData = movies
        } else {
            filteredData = movies?.filter({ (movie: NSDictionary) -> Bool in
                if let title = movie["title"] as? String {
                    if title.range(of: searchText, options: .caseInsensitive) != nil {
                        print("true")
                        return true
                    } else {
                        print("false")
                        return false
                    }
                }
                print("what")
                return false
            })
        }
        
        tableView.reloadData()
    }*/

    // Implemeting the refresh icon called refreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                    print("Refreshing!")
                    self.tableView.reloadData()
                    refreshControl.endRefreshing()
            }
        }
        task.resume()
    }
    

    
    
}
