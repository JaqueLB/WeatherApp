//
//  Weather.swift
//  WeatherApp
//
//  Created by Jaqueline Botaro on 12/10/20.
//

import Foundation
import CoreLocation

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}

struct Weather {
    let description: String
    let icon: String

    init(json: [String:Any]) throws {
        guard let description = json["description"] as? String else { throw SerializationError.missing("description is missing")}

        self.description = description

        guard let icon = json["icon"] as? String else { throw SerializationError.missing("icon is missing")}

        self.icon = icon
    }
}

struct Temperature {
    let day: Double
    init(json: [String:Any]) throws {
        guard let day = json["day"] as? Double else { throw SerializationError.missing("day is missing")}

        self.day = day
    }
}

struct Forecast {
    let temp: Temperature
    var weather: [Weather]
    init(json: [String:Any]) throws {
        self.weather = []

        if let jsonWeather = json["weather"] as? [[String:Any]] {
            for weatherItem in jsonWeather {
                if let weather = try? Weather(json: weatherItem) {
                    self.weather.append(weather)
                }
            }
        } else { throw SerializationError.missing("weather is missing") }

        if let jsonTemp = json["temp"] as? [String:Any] {
            if let temp = try? Temperature(json: jsonTemp) {
                self.temp = temp
            } else { throw SerializationError.missing("temp is missing") }
        } else { throw SerializationError.missing("temp is missing") }
    }

    static let basePath="https://api.openweathermap.org/data/2.5/onecall?exclude=minutely,hourly&appid=f3..37&lang=pt_br&units=metric"

    static func fetch(withLocation location: CLLocationCoordinate2D, completion: @escaping ([Forecast]) -> ()) {
        let url = basePath + "&lat=\(location.latitude)&lon=\(location.longitude)"
        let request = URLRequest(url: URL(string: url)!)

        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            var forecastArray:[Forecast] = []
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [[String:Any]] {
                            for dailyItem in dailyForecasts {
                                if let weatherObj = try? Forecast(json: dailyItem) {
                                    forecastArray.append(weatherObj)
                                }
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        task.resume()
    }
}
