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
    static func weatherFetch(location : CLLocation) -> Observable<weatherModel>{
        return Observable.create { observer in
            Task {
                do {
                    let weather = try await WeatherService.shared.weather(for: location)
                    if let highTemperature = weather.dailyForecast.first?.highTemperature,
                       let lowTemperature = weather.dailyForecast.first?.lowTemperature{
                        let temperature = weather.currentWeather.temperature
                        let Temp = String(describing: temperature)
                        let HighTemp = String(describing:highTemperature)
                        let LowTemp = String(describing:lowTemperature)
                        let symbol = weather.currentWeather.symbolName
                        observer.onNext(weatherModel(Temp: Temp, HighTemp: HighTemp, LowTemp: LowTemp, symbol: symbol))
                    } else {}
                } catch {
                    print(String(describing: error))
                }
            }
            return Disposables.create()
        }
    }
}
