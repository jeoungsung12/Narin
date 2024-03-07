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
    //오늘의 요일
    private let date : UILabel = {
        let label = UILabel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
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
    private let dailyTitle : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .gray
        label.backgroundColor = .white
        label.text = "날씨"
        return label
    }()
    //목소리 스크롤
    private let dailyScrollView : UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .white
        view.isScrollEnabled = true
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    //목소리 스택
    private let dailyStackView : UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .equalCentering
        view.spacing = 20
        view.backgroundColor = .white
        return view
    }()
    private let appleWeatherText : UITextView = {
        let view = UITextView()
        view.text = " Weather\n\nhttps://weatherkit.apple.com/legal-attribution.html"
        view.textColor = .gray
        view.font = UIFont.boldSystemFont(ofSize: 10)
        view.textAlignment = .center
        return view
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()// 설정 버튼 생성
        let settingBtn = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(Alert))
        self.navigationController?.navigationBar.tintColor = .gray
        self.navigationItem.rightBarButtonItem = settingBtn
        self.view.backgroundColor = .pointColor
        self.navigationItem.hidesBackButton = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
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
        self.view.addSubview(date)
        self.view.addSubview(temprange)
        self.view.addSubview(weather)
        self.view.addSubview(weatherImage)
        self.view.addSubview(loadingIndicator)
        self.view.addSubview(location)
        
        //목소리 뷰
        let dailyView = UIView()
        dailyView.backgroundColor = .white
        dailyView.addSubview(dailyTitle)
        AddDailyStackView()
        dailyView.addSubview(dailyScrollView)
        dailyTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.height.equalTo(30)
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-10)
        }
        dailyScrollView.snp.makeConstraints { make in
            make.top.equalTo(dailyTitle.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-70)
        }
        dailyView.addSubview(appleWeatherText)
        appleWeatherText.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(10)
            make.top.equalTo(dailyScrollView.snp.bottom).offset(0)
        }
        self.view.addSubview(dailyView)
        
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
            make.top.equalTo(temprange.snp.bottom).offset(30)
        }
        weatherImage.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(0)
            make.height.equalTo(130)
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
        dailyView.snp.makeConstraints { make in
            make.top.equalTo(location.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(0)
            make.height.equalTo(200)
        }
        self.loadingIndicator.startAnimating()
    }
    private func AddDailyStackView() {
        for _ in 0...7 {
            let View = UIView()
            View.backgroundColor = .white
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = .gray
            label.backgroundColor = .white
            label.textAlignment = .center
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .white
            View.addSubview(imageView)
            View.addSubview(label)
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(40)
                make.top.leading.trailing.equalToSuperview().inset(0)
            }
            label.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview().inset(0)
            }
            dailyStackView.addArrangedSubview(View)
            View.snp.makeConstraints { make in
                make.width.height.equalTo(70)
            }
        }
        dailyScrollView.addSubview(dailyStackView)
        dailyStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.trailing.top.bottom.equalToSuperview().inset(0)
        }
    }
    @objc func Alert() {
        let Alert = UIAlertController(title: "설정", message: nil, preferredStyle: .alert)
        let timeChange = UIAlertAction(title: "시간 변경",style: .default){ _ in
            self.navigationController?.pushViewController(SaveTimeViewController(), animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .destructive)
        Alert.addAction(timeChange)
        Alert.addAction(cancel)
        self.present(Alert, animated: true)
    }
}
//MARK: - 바인딩 설정
extension MainViewController {
    private func setBinding() {
        mainViewModel.outputResult.subscribe(onNext: { result in
            DispatchQueue.main.async {
                self.temprange.text = "최고 \(result.HighTemp)\n최저 \(result.LowTemp)"
                self.weather.text = "\(result.Temp)"
                self.weatherImage.image = UIImage(systemName: "\(result.symbol)")
                for (index, subview) in self.dailyStackView.arrangedSubviews.enumerated() {
                    for subview in subview.subviews {
                        if let label = subview as? UILabel {
                            let format = DateFormatter()
                            format.dateFormat = "MM.dd"
                            let day = format.string(from: result.dates[index])
                            label.text = day
                        } else if let imageView = subview as? UIImageView {
                            imageView.image = UIImage(systemName: result.symbolNames[index])
                        }
                    }
                }
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
            let seoulLatitude: CLLocationDegrees = 37.5665
            let seoulLongitude: CLLocationDegrees = 126.9780
            let seoulLocation = CLLocation(latitude: seoulLatitude, longitude: seoulLongitude)
            mainViewModel.inputTrigger.onNext(seoulLocation)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        let seoulLatitude: CLLocationDegrees = 37.5665
        let seoulLongitude: CLLocationDegrees = 126.9780
        let seoulLocation = CLLocation(latitude: seoulLatitude, longitude: seoulLongitude)
        mainViewModel.inputTrigger.onNext(seoulLocation)
        self.dailyTitle.text = "정확한 예측을 위해 위치정보 허용이 필요합니다."
        print("Defaulting to Seoul: \(seoulLocation)")
    }
}
