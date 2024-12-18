//
//  CarInfoViewController.swift
//  HCar
//
//  Created by User on 12/18/24.
//

import UIKit
import FirebaseFirestore

class CarInfoViewController: UIViewController {
    var car: Car?
    
    @IBOutlet weak var imageViewCar: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelYear: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
    @IBOutlet weak var buttonPurchase: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let car = car {
            labelName.text = car.name
            labelPrice.text = String(car.price)
            labelYear.text = String(car.year)
            labelDetail.text = car.details
            
            // 버튼 셋팅
            if let isSale = car.isSale {
                self.buttonPurchase.isEnabled = false
                self.buttonPurchase.setTitle("구매 완료된 차량입니다", for: .normal)
            }
            
            /// 차량 이미지 비동기적으로 불러오기
            if let url = URL(string: car.image) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Error loading image: \(error)")
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imageViewCar.image = image
                        }
                    }
                }.resume()
            }
        }
    }
    
    @IBAction func purchase(_ sender: UIButton) {
        let alertController = UIAlertController(title: "차량구매", message: "차량을 구매하시겠습니까?", preferredStyle: .actionSheet)
        // 구입 액션
        let purchaseAction = UIAlertAction(title: "구매", style: .default) { _ in
            let db = Firestore.firestore()
            if let car = self.car, let id = car.id {
                db.collection("cars").document(id).updateData(["isSale": true]) { updateError in
                    if let updateError = updateError {
                        print("Error updating isSale: \(updateError)")
                    } else {
                        print("isSale successfully updated")
                        self.buttonPurchase.isEnabled = false
                        self.buttonPurchase.setTitle("구매 완료된 차량입니다", for: .normal)
                    }
                }
            }
        }
        // 취소 액션
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        // 액션 추가
        alertController.addAction(purchaseAction)
        alertController.addAction(cancelAction)
        // 알러트 표시
        present(alertController, animated: true, completion: nil)
    }
}
