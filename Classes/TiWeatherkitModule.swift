//
//  TiWeatherkitModule.swift
//  titanium-weather-kit
//
//  Created by Hans Knöchel
//  Copyright (c) 2022 TiDev. All rights reserved.
//

import UIKit
import TitaniumKit
import WeatherKit

@objc(TiWeatherkitModule)
@available(iOS 16.0, *)
class TiWeatherkitModule: TiModule {
  
  func moduleGUID() -> String {
    return "869eaa97-9e07-4942-9f52-cfc2a4deb06e"
  }
  
  override func moduleId() -> String! {
    return "ti.weatherkit"
  }
  
  @objc(getWeather:)
  func getWeather(args: [Any]) {
    guard let params = args.first as? [String: Any],
    let callback = params["callback"] as? KrollCallback else { return }
    
    let location = CLLocation(latitude: params["latitude"] as! CLLocationDegrees,
                              longitude: params["longitude"] as! CLLocationDegrees)
    
    Task {
      do {
        let weather = try await WeatherService.shared.weather(for: location)
                
        let weatherData: [String: Any] = [
          "success": true,
          "currentWeather": mapped(weather.currentWeather),
          "availability": [
            "alertAvailability": weather.availability.alertAvailability.rawValue,
            "minuteAvailability": weather.availability.minuteAvailability.rawValue
          ],
          // TODO: Map these as well
          "minuteForecast": [:],
          "hourlyForecast": [:],
          "dailyForecast": [:],
          "weatherAlerts": []
        ]
        
        DispatchQueue.main.async {
          callback.call([weatherData], thisObject: self)
        }
      } catch {
        DispatchQueue.main.async {
          callback.call([["success": false, "error": error.localizedDescription]], thisObject: self)
        }
      }
    }
  }
}

// MARK: Mapping Utils

@available(iOS 16.0, *)
extension TiWeatherkitModule {
  
  private func mapped(_ currentWeather: CurrentWeather) -> [String: Any] {
    let currentWeatherMap: [String: Any] = [
      "date": currentWeather.date,
      "cloudCover": currentWeather.cloudCover,
      "condition": currentWeather.condition.rawValue,
      "symbolName": currentWeather.symbolName,
      "dewPoint": currentWeather.dewPoint.formatted(),
      "humidity": currentWeather.humidity,
      "pressure": currentWeather.pressure.formatted(),
      "pressureTrend": currentWeather.pressureTrend.rawValue,
      "isDaylight": currentWeather.isDaylight,
      "temperature": currentWeather.temperature.formatted(),
      "apparentTemperature": currentWeather.apparentTemperature.formatted(),
      "uvIndex": [
        "value": currentWeather.uvIndex.value,
        "category": currentWeather.uvIndex.category.rawValue
      ],
      "visibility": currentWeather.visibility.formatted(),
      "wind": [
        "direction": currentWeather.wind.direction,
        "compassDirection": currentWeather.wind.compassDirection,
        "gust": currentWeather.wind.gust?.formatted() ?? "",
        "speed": currentWeather.wind.speed.formatted(),
      ],
      "metadata": [
        "location": [
          "latitude": currentWeather.metadata.location.coordinate.latitude,
          "longitude": currentWeather.metadata.location.coordinate.longitude,
        ],
        "date": currentWeather.metadata.date,
        "expirationDate": currentWeather.metadata.expirationDate
      ]
    ]

    return [
      "currentWeather": currentWeatherMap
    ]
  }
}
