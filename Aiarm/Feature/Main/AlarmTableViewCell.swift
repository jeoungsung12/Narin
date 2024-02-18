//
//  AlarmTableViewCell.swift
//  Aiarm
//
//  Created by 정성윤 on 2024/02/06.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class AlarmTableViewCell : UITableViewCell {
    private let disposeBag = DisposeBag()
    static let identifier : String = "AlarmTableViewCell"
    //알람 제목
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    //알람 시간
    private let alarmTime : UILabel = {
        let time = UILabel()
        time.textColor = .black
        time.textAlignment = .left
        time.font = UIFont.boldSystemFont(ofSize: 40)
        return time
    }()
    //알람 요일
    private let day : UILabel = {
        let day = UILabel()
        day.textColor = .black
        day.textAlignment = .left
        day.font = UIFont.systemFont(ofSize: 15)
        return day
    }()
    //토글
    private let toggle : UISwitch = {
        let toggle = UISwitch()
        toggle.backgroundColor = .white
        toggle.onTintColor = .pointColor
        return toggle
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .keyColor
        setupLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder: has not been implemented")
    }
}
//MARK: - 오토레이아웃 설정
extension AlarmTableViewCell {
    func setupLayout() {
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 10
        contentView.addSubview(titleLabel)
        contentView.addSubview(alarmTime)
        contentView.addSubview(day)
        contentView.addSubview(toggle)
        contentView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(200)
        }
        titleLabel.snp.makeConstraints { make in make.top.leading.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        alarmTime.snp.makeConstraints { make in make.leading.equalToSuperview().inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
        day.snp.makeConstraints { make in make.bottom.leading.equalToSuperview().inset(20)
            make.top.equalTo(alarmTime.snp.bottom).offset(20)
        }
        toggle.snp.makeConstraints { make in make.top.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
    }
}
//MARK: - 셀에 알림 정보를 표시
extension AlarmTableViewCell {
    func configure(with alarm: AlarmModel) {
        titleLabel.text = alarm.title
        day.text = alarm.day
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        alarmTime.text = formatter.string(from: alarm.time)
        
        //알람 활성화 상태에 따라 토글 상태 변경
        toggle.isOn = true //처음에는 항상 활성화
        
        //토글 이벤트 처리
        toggle.rx.isOn
            .subscribe(onNext: { isOn in
                //알람 활성화 상태 변경에 대한 로직
                
            })
            .disposed(by: disposeBag)
    }
}
