//
//  SaveTimeViewController.swift
//  Aiarm
//
//  Created by 정성윤 on 2024/02/06.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
import UIKit

class SaveTimeViewController : UIViewController {
    private let disposeBag = DisposeBag()
    private let saveTimeViewModel = SaveTimeViewModel()
    //저장버튼
    private let saveBtn : UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "저장", style: .plain, target: SaveTimeViewController.self, action: nil)
        btn.tintColor = .blue
        return btn
    }()
    //로고 이미지
    private let weatherImage : UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "background")
        return view
    }()
    //알람 설명
    private let descriptionText : UITextView = {
        let text = UITextView()
        text.backgroundColor = .white
        text.textAlignment = .left
        text.isEditable = false
        text.textColor = .gray
        text.text = "알림을 받을 시간을 선택하세요!\n\n매일 자정 기상에 맞게 목소리가 업데이트 됩니다!\n(알림 이용 불가 시간 : 자정 ~ 05시)"
        text.font = UIFont.boldSystemFont(ofSize: 15)
        return text
    }()
    //알람 설정
    private let alarmSetting : UIDatePicker = {
        let date = UIDatePicker()
        date.datePickerMode = .time
        date.preferredDatePickerStyle = .wheels
        date.backgroundColor = .white
        date.layer.cornerRadius = 10
        date.layer.masksToBounds = true
        return date
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .blue
        setLayout()
        setBinding()
    }
}
//MARK: - 레이아웃 설정
extension SaveTimeViewController {
    private func setLayout() {
        self.navigationItem.rightBarButtonItem = saveBtn
        self.view.addSubview(weatherImage)
        self.view.addSubview(descriptionText)
        self.view.addSubview(alarmSetting)
        weatherImage.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(0)
            make.height.equalTo(230)
            make.center.equalToSuperview().offset(-200)
        }
        descriptionText.snp.makeConstraints { make in
            make.top.equalTo(weatherImage.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        alarmSetting.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.top.equalTo(descriptionText.snp.bottom).offset(30)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
}
//MARK: - 바인딩
extension SaveTimeViewController {
    private func setBinding() {
        saveBtn.rx.tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else {return}
                // 선택한 시간을 데이터 포맷으로 변환
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "a h:mm"
                let selectedTime = dateFormatter.string(from: self.alarmSetting.date)
                self.saveTimeViewModel.inputTrigger.onNext(selectedTime)
                navigationController?.pushViewController(MainViewController(), animated: true)
            })
            .disposed(by: disposeBag)
    }
}
