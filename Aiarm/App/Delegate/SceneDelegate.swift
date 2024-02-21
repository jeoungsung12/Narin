//
//  SceneDelegate.swift
//  Aiarm
//
//  Created by 정성윤 on 2024/02/06.
//

import UIKit
import UserNotifications
class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?
    var timer: Timer?
    let userDefaults = UserDefaults.standard

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else {return}
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = SaveTimeViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible() //화면에 보이게끔
        window?.windowScene = windowScene
        UNUserNotificationCenter.current().delegate = self
        startBackgroundTimer()
    }
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        timer?.invalidate() //타이머 중지
        timer = nil
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        sendLocalNotification()
        print("백그라운드 시작")
    }
    
    @objc func checkTime() {
        print("타임 체크시작")
        guard let savedTime = userDefaults.string(forKey: "SaveTime") else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h:mm"
        let currentTime = dateFormatter.string(from: Date())
        
        if currentTime == savedTime {
            sendLocalNotification()
        }
    }
    func sendLocalNotification() {
        guard let savedTime = userDefaults.string(forKey: "SaveTime") else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h:mm"
        guard let date = dateFormatter.date(from: savedTime) else {
            print("Failed to convert saved time to Date object")
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "나린"
        content.body = "오늘의 날씨 알림입니다."
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "차승원.wav"))
        
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
    func startBackgroundTimer() {
        print("타이머 시작")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkTime), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .common)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("알람 수신")
        completionHandler()
    }
}

