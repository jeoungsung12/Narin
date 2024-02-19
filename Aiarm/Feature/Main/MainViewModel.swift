//
//  MainViewModel.swift
//  Aiarm
//
//  Created by 정성윤 on 2024/02/06.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

class MainViewModel {
    private let disposeBag = DisposeBag()
    let inputTrigger = PublishSubject<CLLocation>()
    let outputResult : PublishSubject<weatherModel> = PublishSubject()
    let locationResult : PublishSubject<String> = PublishSubject()
    init() {
        setBinding()
    }
    func setBinding() {
        inputTrigger.flatMapLatest { location in
            return WeatherFetch.weatherFetch(location: location)
        }
        .bind(to: outputResult)
        .disposed(by: disposeBag)
        inputTrigger.flatMapLatest { location in
            return self.getLocationName(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        .bind(to: locationResult)
        .disposed(by: disposeBag)
    }
}
//위도 경도로 위치정보 가져오기
extension MainViewModel {
    func getLocationName(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Observable<String> {
        return Observable.create { observer in
            print()
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                if let locality = placemark.locality, let subLocality = placemark.subLocality {
                    let locationName : String = ("\(locality) \(subLocality)")
                    observer.onNext(locationName)
                    observer.onCompleted()
                } else {
                    print("위치 에러")
                }
            }
            return Disposables.create()
        }
    }
}
