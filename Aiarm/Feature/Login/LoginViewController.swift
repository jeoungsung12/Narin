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

class LoginViewController : UIViewController{
    private let disposeBag = DisposeBag()
    private let loginViewModel = LoginViewModel()
    //이미지 배경
    private let imageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .white
        view.image = UIImage(named: "AppLogoShadow")
        return view
    }()
    //애플로그인 버튼
    private let appleBtn : ASAuthorizationAppleIDButton = {
        let btn = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        btn.cornerRadius = 10
        return btn
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .keyColor
        setLayout()
        setBinding()
    }
}
//MARK: - Layout
extension LoginViewController {
    private func setLayout() {
        self.view.addSubview(imageView)
        self.view.addSubview(appleBtn)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(0)
            make.center.equalToSuperview()
            make.height.equalTo(360)
        }
        appleBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(50)
            make.top.equalTo(imageView.snp.bottom).offset(50)
        }
    }
}
//MARK: - Binding
extension LoginViewController {
    private func setBinding() {
        appleBtn.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.handleAppleSignInButtonPress()
            })
            .disposed(by: disposeBag)
    }
}
//MARK: - AppleLogin
extension LoginViewController : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private func handleAppleSignInButtonPress() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userId = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("User ID: \(userId)")
            print("Full Name: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
            print("Email: \(email ?? "")")
            self.navigationController?.pushViewController(SaveTimeViewController(), animated: true)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign In Error: \(error.localizedDescription)")
    }
}
