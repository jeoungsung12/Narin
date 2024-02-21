//
//  ViewController.swift
//  Aiarm
//
//  Created by 정성윤 on 2024/02/06.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import CoreLocation
import AVFoundation
class MainViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    private let disposeBag = DisposeBag()
    private let mainViewModel = MainViewModel()
    private let locationManager = CLLocationManager()
    private let loadingIndicator : UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .gray
        view.style = .large
        return view
    }()
    //설정 버튼
    private let settingBtn : UIBarButtonItem = {
        let setting = UIButton()
        setting.tintColor = .gray
        setting.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        let btn = UIBarButtonItem(customView: setting)
        return btn
    }()
    //오늘의 요일
    private let date : UILabel = {
        let label = UILabel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd"
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        label.text = dateString
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 45)
        label.textAlignment = .left
        label.backgroundColor = .pointColor
        return label
    }()
    //일교차
    private let temprange : UITextView = {
        let text = UITextView()
        text.textAlignment = .left
        text.isEditable = false
        text.textColor = .gray
        text.font = UIFont.boldSystemFont(ofSize: 24)
        text.text = "-"
        text.backgroundColor = .pointColor
        return text
    }()
    //대략적인 날씨
    private let weather : UILabel = {
        let label = UILabel()
        label.text = "-"
        label.textColor = .black
        label.backgroundColor = .pointColor
        label.font = UIFont.boldSystemFont(ofSize: 45)
        label.textAlignment = .left
        return label
    }()
    //날씨 이미지
    private let weatherImage : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .pointColor
        view.image = UIImage(systemName: "")
        return view
    }()
    //현재위치
    private let location : UILabel = {
        let label = UILabel()
        label.backgroundColor = .pointColor
        label.text = "-"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .gray
        label.textAlignment = .left
        return label
    }()
    //목소리 선택타이틀
    private let voiceTitle : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .gray
        label.backgroundColor = .white
        label.text = "알림을 받을 목소리를 선택하세요!"
        return label
    }()
    //목소리 스크롤
    private let voiceScrollView : UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .white
        view.isScrollEnabled = true
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    //목소리 스택
    private let voiceStackView : UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .equalCentering
        view.spacing = 20
        view.backgroundColor = .white
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .pointColor
        self.navigationItem.hidesBackButton = true
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("알림 권한이 사용자에게 성공적으로 허용되었습니다.")
            } else {
                print("사용자가 알림 권한을 거부했습니다.")
            }
        }
        setLayout()
        setBinding()
    }
}
//MARK: - 오토레이아웃 설정
extension MainViewController {
    private func setLayout() {
        //추가버튼과 수정버튼 설정
        self.navigationItem.rightBarButtonItem = settingBtn
        self.view.addSubview(date)
        self.view.addSubview(temprange)
        self.view.addSubview(weather)
        self.view.addSubview(weatherImage)
        self.view.addSubview(loadingIndicator)
        self.view.addSubview(location)
        
        //목소리 뷰
        let VoiceView = UIView()
        VoiceView.backgroundColor = .white
        VoiceView.addSubview(voiceTitle)
        AddVoiceStackView()
        VoiceView.addSubview(voiceScrollView)
        voiceTitle.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(30)
            make.height.equalTo(30)
        }
        voiceScrollView.snp.makeConstraints { make in
            make.top.equalTo(voiceTitle.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(0)
        }
        self.view.addSubview(VoiceView)
        
        date.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalToSuperview().offset(self.view.frame.height / 8.5)
            make.leading.equalToSuperview().offset(30)
        }
        temprange.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.leading.trailing.equalToSuperview().inset(30)
            make.top.equalTo(date.snp.bottom).offset(20)
        }
        weather.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(50)
            make.top.equalTo(temprange.snp.bottom).offset(50)
        }
        weatherImage.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(0)
            make.height.equalTo(160)
            make.center.equalToSuperview()
        }
        loadingIndicator.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(weatherImage.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview().inset(0)
        }
        location.snp.makeConstraints { make in
            make.top.equalTo(weatherImage.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(20)
        }
        VoiceView.snp.makeConstraints { make in
            make.top.equalTo(location.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(0)
            make.height.equalTo(200)
        }
        self.loadingIndicator.startAnimating()
    }
    private func AddVoiceStackView() {
        let voiceList : [String] = ["아이유","수지","지디","김민석"]
        let btnColors : [UIColor] = [.voiceColor1,.voiceColor2,.voiceColor3,.voiceColor4,.pointColor]
        var index = 0
        voiceList.forEach { voice in
            let Button = UIButton()
            Button.backgroundColor = btnColors[index]
            index += 1
            Button.setTitle(voice, for: .normal)
            Button.setTitleColor(.darkGray, for: .normal)
            Button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            Button.layer.cornerRadius = 20
            Button.snp.makeConstraints { make in make.width.height.equalTo(70) }
            voiceStackView.addArrangedSubview(Button)
        }
        voiceScrollView.addSubview(voiceStackView)
        voiceStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().inset(0)
        }
    }
    @objc func Alert() {
        let Alert = UIAlertController(title: "설정", message: nil, preferredStyle: .alert)
        let timeChange = UIAlertAction(title: "시간 변경", style: .default){ _ in
            self.navigationController?.pushViewController(SaveTimeViewController(), animated: true)
        }
        let logout = UIAlertAction(title: "로그아웃", style: .default){ _ in
            self.navigationController?.pushViewController(LoginViewController(), animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .destructive)
        Alert.addAction(timeChange)
        Alert.addAction(logout)
        Alert.addAction(cancel)
        self.present(Alert, animated: true)
    }
}
//MARK: - 바인딩 설정
extension MainViewController {
    private func setBinding() {
        voiceStackView.subviews.compactMap { $0 as? UIButton }.forEach { button in
            button.rx.tap
                .subscribe(onNext: { _ in
                    guard (button.titleLabel?.text) != nil else { return }
                    button.layer.shadowColor = UIColor.gray.cgColor
                    button.layer.shadowOffset = CGSize(width: 5, height: 5)
                    button.layer.shadowOpacity = 5
                })
                .disposed(by: disposeBag)
        }
        if let button = settingBtn.customView as? UIButton {
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.Alert()
                })
                .disposed(by: disposeBag)
        }
        mainViewModel.outputResult.subscribe(onNext: { result in
            DispatchQueue.main.async {
                self.temprange.text = "최고 \(result.HighTemp)\n최저 \(result.LowTemp)"
                self.weather.text = "\(result.Temp)"
                self.weatherImage.image = UIImage(systemName: "\(result.symbol)")
                self.loadingIndicator.stopAnimating()
            }
        })
        .disposed(by: disposeBag)
        mainViewModel.locationResult.subscribe(onNext: { location in
            DispatchQueue.main.async {
                self.location.text = location
            }
        })
        .disposed(by: disposeBag)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mainViewModel.inputTrigger.onNext(location)
        }else{
            //에러가 났을 경우 다시 요청
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
