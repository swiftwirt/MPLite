//
//  FirstViewController.swift
//  TanzAbend
//
//  Created by Ivashin Dmitry on 9/28/16.
//  Copyright © 2016 Ivashin Dmitry. All rights reserved.
//

import UIKit

class SearchMusicViewController: UIViewController {
    
    struct ReuseIdentifiersForCells {
        static let trackCell = "TrackCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var requestURL: URL!
    var searchCategoryIndex = 0
    var isLoading = false
    var hasSearched = false
    
    var searchResults = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nothingFoundCellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        tableView.register(nothingFoundCellNib, forCellReuseIdentifier: ReuseIdentifiersForCells.nothingFoundCell)
        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(loadingCellNib, forCellReuseIdentifier: ReuseIdentifiersForCells.loadingCell)
        if segmentedControl.selectedSegmentIndex == 0 {
            requestURL = URL(string: "https://freemusicarchive.org/featured.json")
            performSearch(URL: requestURL)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentInset = UIEdgeInsets(top: 80.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    @IBAction func segmentDidChanged(_ sender: UISegmentedControl) {
        searchCategoryIndex = sender.selectedSegmentIndex
        switch searchCategoryIndex {
        case 0:
            requestURL = URL(string: "https://freemusicarchive.org/featured.json")
            performSearch(URL: requestURL)
        case 1:
            requestURL = URL(string: "https://freemusicarchive.org/recent.json")
            performSearch(URL: requestURL)
        case 2:
//            requestURL = getURLfrom(searchText: searchBar.text!)
//            if !hasSearched {
//                performSearch(URL: requestURL)
//            }
            hasSearched = false
            tableView.reloadData()
        default:
            return
        }
    }
    
    func performSearch(URL: URL) {
        isLoading = true
        hasSearched = true
        tableView.reloadData()
        let session = URLSession.shared
        let dataTask = session.dataTask(with: URL, completionHandler: {
            data, response, error in
            
            if let error = error {
                print("Failure! \(error)")
            } else {
                print("Success! \(response!)")
                if let data = data, let dictionary = self.parseJSON(data: data) {
                    self.searchResults = self.parseDictionary(dictionary: dictionary)
                    self.searchResults.sort(by: <)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                return
                }
            }
        })
        dataTask.resume()
    }
    
    func parseJSON(data: Data) -> [String: AnyObject]? {
        do {
            return try JSONSerialization.jsonObject(
                with: data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func parseDictionary(dictionary: [String:AnyObject]) -> [SearchResult] {
        guard let array = dictionary["aTracks"] as? [AnyObject] else {
            print("Expected 'aTracks' array")
            return []
        }
        var searchResults = [SearchResult]()
        for resultDict in array {
            let searchResult = SearchResult()
            if let searchResultNonOpt = resultDict["album_title"] as? String {
                 searchResult.album = searchResultNonOpt
            } else {
                searchResult.album = "Unknown"
                print("No album")
            }
            if let searchResultNonOpt = resultDict["artist_name"] as? String {
                searchResult.artist = searchResultNonOpt
            } else {
                searchResult.artist = "No info"
                print("No artist")
            }
            if let searchResultNonOpt = resultDict["track_title"] as? String {
                searchResult.track = searchResultNonOpt
            } else {
                searchResult.track = "Unknown"
                print("No track")
            }
            if let searchResultNonOpt = resultDict["track_file_url"] as? String {
                searchResult.trackDownloadLink = searchResultNonOpt
            } else {
                print("No download url")
            }
            if let searchResultNonOpt = resultDict["album_image_file"] as? String {
                searchResult.albumImageLink += searchResultNonOpt
            } else {
                print("No image url")
                if let searchResultNonOpt = resultDict["track_image_file"] as? String {
                    searchResult.albumImageLink = searchResultNonOpt
                }
            }
            
            searchResults.append(searchResult)
        }
        return searchResults
    }

    
    func getURLfrom(searchText: String) -> URL {
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let urlString = String(format:
            "https://SAERCH_API", escapedSearchText!)
        let url = URL(string: urlString)
        return url!
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message:
            "There was an error reading from the iTunes Store. Please try again.",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let controller = segue.destination as! PlayerPopUpViewController
            let indexPath = IndexPath(row: (sender! as AnyObject).tag!, section: 0)
            controller.searchResult = searchResults[indexPath.row]
        }
    }
    
    @IBAction func play(_ sender: AnyObject) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
}

extension SearchMusicViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 || isLoading {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiersForCells.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if searchResults.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiersForCells.nothingFoundCell, for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiersForCells.trackCell, for: indexPath) as! TrackCell
            let searchResult = searchResults[indexPath.row]
            cell.albumLabel.text = searchResult.album
            cell.artistLabel.text = searchResult.artist
            cell.trackLabel.text = searchResult.track
            cell.playBtn.tag = indexPath.row
            cell.configureImageForSearchResult(searchResult: searchResult)
            return cell
        }
    }
}

extension SearchMusicViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
      
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension SearchMusicViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let url = getURLfrom(searchText: searchBar.text!)
        performSearch(URL: url)
        hasSearched = true
        segmentedControl.selectedSegmentIndex = 2
        print("The search text is: '\(searchBar.text!)'")
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

