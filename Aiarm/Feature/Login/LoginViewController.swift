//
//  LoginViewController.swift
//  Aiarm
//
//  Created by 정성윤 on 2024/02/16.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import AuthenticationServices
import CoreLocation

class LoginViewController : UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate{
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    //이미지 배경
    private let imageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .keyColor
        view.image = UIImage(named: "AppLogoShadow")
        return view
    }()
    //시작하기 버튼
    private let startBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("시작하기", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.titleLabel?.textAlignment = .center
        btn.backgroundColor = .clear
        return btn
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .keyColor
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("알림 권한이 사용자에게 성공적으로 허용되었습니다.")
            } else {
                print("사용자가 알림 권한을 거부했습니다.")
                self.Alert()
            }
        }
        setLayout()
        setBinding()
    }
}
//MARK: - Layout
extension LoginViewController {
    private func setLayout() {
        self.view.addSubview(imageView)
        self.view.addSubview(startBtn)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(0)
            make.center.equalToSuperview()
            make.height.equalTo(360)
        }
        startBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(0)
            make.top.equalTo(imageView.snp.bottom).offset(100)
        }
    }
}
//MARK: - Binding
extension LoginViewController {
    private func setBinding() {
        startBtn.rx.tap
            .subscribe { _ in
                UserDefaults.standard.set("Success", forKey: "Auth")
                self.navigationController?.pushViewController(SaveTimeViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("\(location)")
        }else{
            self.Alert()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        self.Alert()
    }
    func Alert() {
        let Alert = UIAlertController(title: "알림/시간 허용", message: "날씨 예측/알림 위해 위치정보 및 알림 허용이 필요합니다.", preferredStyle: .alert)
        let Ok = UIAlertAction(title: "확인", style: .default){ _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
        }
        let cancel = UIAlertAction(title: "취소", style: .destructive)
        Alert.addAction(Ok)
        Alert.addAction(cancel)
        self.present(Alert, animated: true)
    }
}
