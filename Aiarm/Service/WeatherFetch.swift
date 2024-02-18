//
//  WeatherFetch.swift
//  Aiarm
//
//  Created by 정성윤 on 2024/02/18.
//

import Foundation
import WeatherKit
import RxSwift
import RxCocoa
import CoreLocation

class WeatherFetch {
    static func weatherFetch(location : CLLocation) -> Observable<Void>{
        return Observable.create { observer in
            Task {
                do {
                    let weather = try await WeatherService.shared.weather(for: location)
                    
                    print("Temp: \(weather.currentWeather.temperature)")
                    print("최고기온: \(String(describing: weather.dailyForecast.first?.highTemperature))")
                    print("최저기온: \(String(describing: weather.dailyForecast.first?.lowTemperature))")
                    print("symbol: \(weather.currentWeather.symbolName)")
                    
                    
                } catch {
                    print(String(describing: error))
                }
            }
            return Disposables.create()
        }
    }
}
