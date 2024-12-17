//
//  IntroViewController.swift
//  HCar
//
//  Created by User on 12/17/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

enum SignupOrLogin {
    case signup
    case login
}

class IntroViewController: UIViewController {
    @IBOutlet weak var textFieldNick: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPW: UITextField!
    @IBOutlet weak var buttomComplete: UIButton!
    
    var signupOrLogin = SignupOrLogin.signup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            signupOrLogin = .signup
            textFieldNick.isHidden = false
            buttomComplete.setTitle("회원가입", for: .normal)
        } else if sender.selectedSegmentIndex == 1 {
            signupOrLogin = .login
            textFieldNick.isHidden = true
            buttomComplete.setTitle("로그인", for: .normal)
        }
    }
    
    @IBAction func complete(_ sender: UIButton) {
        switch signupOrLogin {
        case .signup:
            signUp()
        case .login:
            login()
        }
    }
    
    func signUp() {
        guard let email = textFieldEmail.text, !email.isEmpty,
              let password = textFieldPW.text, !password.isEmpty,
              let nickname = textFieldNick.text, !nickname.isEmpty else {
            showAlert(title: "Error", message: "모든 필드를 입력해주세요.")
            return
        }
        
        // Firebase Auth로 회원가입
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                self.showAlert(title: "회원가입 오류", message: error.localizedDescription)
                return
            }
            
            // Firebase Auth가 성공적으로 완료되면 Firestore에 유저 정보 저장
            self.saveUser(email: email, nickname: nickname)
        }
    }
    
    func login() {
        guard let email = textFieldEmail.text, !email.isEmpty,
              let password = textFieldPW.text, !password.isEmpty else {
            showAlert(title: "Error", message: "이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        // Firebase Auth로 로그인
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                self.showAlert(title: "로그인 오류", message: error.localizedDescription)
                return
            }
            
            // 로그인 성공
            self.navigateToHomeScreen()
        }
    }
    
    func saveUser(email: String, nickname: String) {
        let user = User(email: email, nickname: nickname)
        let db = Firestore.firestore()
        
        // Firestore에 사용자 데이터 저장
        db.collection("users").document(Auth.auth().currentUser!.uid).setData([
            "email": user.email,
            "nickname": user.nickname
        ]) { error in
            if let error = error {
                self.showAlert(title: "Firestore 오류", message: error.localizedDescription)
            } else {
                // 회원가입 성공
                self.navigateToHomeScreen()
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // 로그인 후 홈 화면으로 이동
    func navigateToHomeScreen() {
        // 예시로 다른 화면으로 이동
        if let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBarController") {
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
}
