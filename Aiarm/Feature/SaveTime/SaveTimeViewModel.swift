//
//  AddAlarmViewModel.swift
//  Aiarm
//
//  Created by 정성윤 on 2024/02/06.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SaveTimeViewModel {
    private let disposeBag = DisposeBag()
    let inputTrigger = PublishSubject<String>()
    let outputResult : PublishSubject<Void> = PublishSubject()
    
    init() {
        setBinding()
    }
    func setBinding() {
        inputTrigger.subscribe(onNext: { selectedTime in
            UserDefaults.standard.setValue(selectedTime, forKey: "SaveTime")
        })
        .disposed(by: disposeBag)
    }
}
