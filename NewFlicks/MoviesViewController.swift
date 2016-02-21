//
//  MoviesViewController.swift
//  NewFlicks
//
//  Created by Besart Aliju on 2/14/16.
//  Copyright © 2016 Besart Aliju. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkLabel: UILabel!
    
    
    
    
    var movies: [NSDictionary]?
    let refreshControl = UIRefreshControl()
    var endpoint: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Reachability.isConnectedToNetwork() == true {
            //println("Internet connection OK")
            networkLabel.hidden = true
        } else {
            //println("Internet connection FAILED")
            tableView.alpha = 10.0
            networkLabel.backgroundColor = UIColor.whiteColor()
            networkLabel.hidden = false
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadDataFromNetwork()
        
        tableView.backgroundColor = UIColor.lightGrayColor()
        
    
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromNetwork() {
        // ... Create the NSURLRequest (myRequest) ...
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.tableView.reloadData()
                    }
                }
                
        });
        task.resume()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let movies = movies{
            return movies.count
        } else {
            return 0
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        if Reachability.isConnectedToNetwork() == true {
            //println("Internet connection OK")
            networkLabel.hidden = true
            // ... Create the NSURLRequest (request) ...
            let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
            let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
            let request = NSURLRequest(
                URL: url!,
                cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            
            
            // Configure session so that completion handler is executed on main UI thread
            let session = NSURLSession(
                configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                delegate:nil,
                delegateQueue:NSOperationQueue.mainQueue()
            )
            
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                completionHandler: { (dataOrNil, response, error) in
                    
                    // ... Use the new data to update the data source ...
                    if let data = dataOrNil {
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                            data, options:[]) as? NSDictionary {
                                print("response: \(responseDictionary)")
                                
                                self.movies = responseDictionary["results"] as! [NSDictionary]
                                self.tableView.reloadData()
                        }
                    }
                    
                    
                    // Reload the tableView now that there is new data
                    self.tableView.reloadData()
                    
                    // Tell the refreshControl to stop spinning
                    refreshControl.endRefreshing()	
            });
            task.resume()
        } else {
            //println("Internet connection FAILED")
            tableView.alpha = 10.0
            networkLabel.backgroundColor = UIColor.whiteColor()
            networkLabel.hidden = false
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //table view function that runs when an item is selected
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGrayColor()
        backgroundView.alpha = 80.0
        cell.titleLabel.hidden = true
        cell.overviewLabel.hidden = true
        cell.selectedBackgroundView = backgroundView
       // print("item selected")
       // print(indexPath)
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        cell.backgroundColor = UIColor.blackColor()
        
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String{
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        
        
       // print("row\(indexPath.row)")
        return cell
    }

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        
        let movie  = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        print("prepare for segue called")
        // Pass the selected object to the new view controller.
    }
    
}
