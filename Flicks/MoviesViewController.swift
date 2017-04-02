//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Mhatre, Aniket on 4/2/17.
//  Copyright © 2017 Mhatre, Aniket. All rights reserved.
//

import UIKit
import AFNetworking
import CircularSpinner

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var errorBannerView: UIView!
    
    @IBOutlet weak var moviesTableView: UITableView!
    
    var movies: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        moviesTableView.insertSubview(refreshControl, at: 0)
        
        CircularSpinner.show("Loading...", animated: true, type: .indeterminate)
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        fetchMovies()
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        fetchMovies(refreshControl)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        
        cell.titleLabel.text = movie["title"] as? String
        cell.overviewLabel.text = movie["overview"] as? String
        
        let baseUrl = "https://image.tmdb.org/t/p/w342/"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(imageUrl as! URL)
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchMovies(_ refreshControl: UIRefreshControl? = nil) {
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if error != nil {
                    self.errorBannerView.isHidden = false
                } else {
                    self.errorBannerView.isHidden = true
                    if let data = data {
                        if let responseDictionary = try! JSONSerialization.jsonObject(
                            with: data, options:[]) as? NSDictionary {
                            
                            // This is how we get the 'response' results
                            let resultsFieldDictionary = responseDictionary["results"] as! [NSDictionary]
                            self.movies = resultsFieldDictionary
                            self.moviesTableView.reloadData()
                        }
                    }
                }
                
                if let refreshControl = refreshControl {
                    refreshControl.endRefreshing()
                } else {
                    CircularSpinner.hide()
                }
        });
        task.resume()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        let indexPath = moviesTableView.indexPath(for: cell)
        let movie = movies[(indexPath?.row)!]
        
        let detailViewController = segue.destination as! DetailViewController
        
        detailViewController.movie = movie
    }
}
