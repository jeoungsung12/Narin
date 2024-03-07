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
                    let koreanSymbols = weather.dailyForecast.compactMap { translateSymbolName($0.symbolName) }
                    let koreanDates = weather.dailyForecast.compactMap { $0.date }
                    var saveWeather: [String: String] = [:]

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"

                    for i in 0..<min(koreanSymbols.count, koreanDates.count) {
                        let symbol = koreanSymbols[i]
                        let date = dateFormatter.string(from: koreanDates[i])
                        saveWeather[date] = symbol
                    }
                    UserDefaults.standard.removeObject(forKey: "WeatherForecast")
                    UserDefaults.standard.set(saveWeather, forKey: "WeatherForecast")
                    
                    if let highTemperature = weather.dailyForecast.first?.highTemperature,
                       let lowTemperature = weather.dailyForecast.first?.lowTemperature{
                        let temperature = weather.currentWeather.temperature
                        let Temp = String(describing: temperature)
                        let HighTemp = String(describing:highTemperature)
                        let LowTemp = String(describing:lowTemperature)
                        let symbol = weather.currentWeather.symbolName
                        let symbolNames = weather.dailyForecast.compactMap { $0.symbolName }
                        let dates = weather.dailyForecast.compactMap { $0.date }
                        observer.onNext(weatherModel(Temp: Temp, HighTemp: HighTemp, LowTemp: LowTemp, symbol: symbol, dates: dates, symbolNames: symbolNames))
                    } else {}
                } catch {
                    print(String(describing: error))
                }
            }
            return Disposables.create()
        }
    }
    static func translateSymbolName(_ symbolName: String) -> String {
        switch symbolName {
            case "sun.max": return "맑음"
            case "cloud.sun": return "구름 조금"
            case "cloud": return "구름"
            case "cloud.fill": return "흐림"
            case "cloud.rain": return "비"
            case "cloud.bolt.rain": return "천둥 번개"
            case "cloud.snow": return "눈"
            case "cloud.fog": return "안개"
            case "wind": return "바람"
            case "cloud.drizzle": return "이슬비"
            case "cloud.bolt": return "폭풍우"
            case "cloud.hail": return "우박"
            default: return symbolName
        }
    }
}
