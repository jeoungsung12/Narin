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
    let outputResult : PublishSubject<Void> = PublishSubject()
    
    init() {
        setBinding()
    }
    func setBinding() {
        inputTrigger.flatMapLatest { location in
            return WeatherFetch.weatherFetch(location: location)
        }
        .bind(to: outputResult)
        .disposed(by: disposeBag)
    }
}
