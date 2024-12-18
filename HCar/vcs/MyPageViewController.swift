//
//  MyPageViewController.swift
//  HCar
//
//  Created by User on 12/18/24.
//

import UIKit
import FirebaseAuth

class MyPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logout(_ sender: UIButton) {
        logoutUser()
        
    }
    
    func logoutUser() {
        do {
            try Auth.auth().signOut()
            print("로그아웃 성공")
            navigateToIntroScreen()
        } catch let signOutError as NSError {
            print("로그아웃 중 오류 발생: \(signOutError.localizedDescription)")
        }
    }
    
    func navigateToIntroScreen() {
        if let introVC = storyboard?.instantiateViewController(withIdentifier: "introViewController") {
            // 윈도우의 루트 뷰 컨트롤러를 Intro로 변경
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = introVC
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        } else {
            print("introViewController를 찾을 수 없습니다.")
        }
    }
}
