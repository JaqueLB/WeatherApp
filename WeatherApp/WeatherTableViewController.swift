//
//  WeatherTableViewController.swift
//  WeatherApp
//
//  Created by Jaqueline Botaro on 12/10/20.
//

import UIKit
import CoreLocation // to geocode our location string into lat and long

class WeatherTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var forecastData = [Forecast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // for us to use the function that listen
        searchBar.delegate = self
        updateWeather(forLocation: "Sao Paulo")
    }
    // we going to want to listen to that
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // this hides the keyboard
        if let locationString = searchBar.text, !locationString.isEmpty {
            updateWeather(forLocation: locationString)
        }
    }
    
    func updateWeather(forLocation location: String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks: [CLPlacemark]?, error: Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    Forecast.fetch(withLocation: location.coordinate) { (results: [Forecast]?) in
                        if let weatherData = results {
                            self.forecastData = weatherData
                            DispatchQueue.main.async {
                                // this triggers the numberOfSections, numberOfRowsInSection and cellForRowAt delegates
                                self.tableView.reloadData() // to apply to our main processes the change
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return forecastData.count // number of sections = number of days
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // one row presection and per day of info
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Identifier was defined in Storyboard for Protype Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let weatherObject = forecastData[indexPath.section] // row if all data in each section. Now it is section, because one item per section
        
        if let weatherProp = weatherObject.weather.first {
            cell.textLabel?.text = weatherProp.description
            cell.imageView?.image = UIImage(named: weatherProp.icon)
        }
        
        cell.detailTextLabel?.text = "\(Int(weatherObject.temp.day)) ºC"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Calendar.current.date(byAdding: .day, value: section, to: Date()) // each section is a Date starting today
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd, MMMM yyyy"
        return dateFormatter.string(from: date!)
    }
}
