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
    private let mainViewModel : MainViewModel
    //알람 제목, 시간값, 요일, 목소리
    let addAlarm : BehaviorSubject<AddAlarmModel> = BehaviorSubject(value: AddAlarmModel(title: "", date: Date(), days: [""], voice: ""))
    
    init(mainViewModel : MainViewModel) {
        self.mainViewModel = mainViewModel
        setBinding()
    }
    func setBinding() {
        
    }
}
//MARK: - 추가알람 설정(저장버튼 클릭시) 통신서비스 호출
extension SaveTimeViewModel {
    private func AddAlarmServiceCalled(){
        print("AddAlarmServiceCalled - called()")
        
    }
}
