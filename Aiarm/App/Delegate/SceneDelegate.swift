//
//  SceneDelegate.swift
//  Aiarm
//
//  Created by 정성윤 on 2024/02/06.
//

import UIKit
import UserNotifications
import CoreLocation
import RxSwift
class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate{
    var weatherResult = WeatherFetch.weatherFetch(location: CLLocation())
    private let disposeBag = DisposeBag()
    var window: UIWindow?
    let userDefaults = UserDefaults.standard
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else {return}
        window = UIWindow(frame: UIScreen.main.bounds)
        if userDefaults.string(forKey: "Auth") != nil{
            let viewController = MainViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            window?.rootViewController = navigationController
        }else{
            let viewController = LoginViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            window?.rootViewController = navigationController
        }
        window?.makeKeyAndVisible() //화면에 보이게끔
        window?.windowScene = windowScene
        UNUserNotificationCenter.current().delegate = self
    }
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        sendLocalNotification()
    }
    func sendLocalNotification() {
        guard let savedTime = self.userDefaults.string(forKey: "SaveTime") else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h:mm"
        guard let date = dateFormatter.date(from: savedTime) else {
            print("Failed to convert saved time to Date object")
            return
        }
        if let weatherDictionary = UserDefaults.standard.dictionary(forKey: "WeatherForecast") as? [String: String] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let today = dateFormatter.string(from: Date())
            if let weather = weatherDictionary[today] {
                let content = UNMutableNotificationContent()
                content.title = "나린"
                content.body = "\(weather)"
                content.sound = UNNotificationSound.default
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Failed to schedule local notification: \(error.localizedDescription)")
                    } else {
                        print("Local notification scheduled successfully")
                    }
                }
            } else {
                let content = UNMutableNotificationContent()
                content.title = "나린"
                content.body = "앱에 접속해 날씨를 조회해주세요!"
                content.sound = UNNotificationSound.default
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Failed to schedule local notification: \(error.localizedDescription)")
                    } else {
                        print("Local notification scheduled successfully")
                    }
                }
            }
        } else {
            let content = UNMutableNotificationContent()
            content.title = "나린"
            content.body = "앱에 접속해 날씨를 조회해주세요!"
            content.sound = UNNotificationSound.default
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule local notification: \(error.localizedDescription)")
                } else {
                    print("Local notification scheduled successfully")
                }
            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("알람 수신")
        completionHandler()
    }
}

