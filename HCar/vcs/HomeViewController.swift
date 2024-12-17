//
//  ViewController.swift
//  HCar
//
//  Created by User on 12/17/24.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    let db = Firestore.firestore()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 뷰컨트롤러 네비게이션 바 감추기
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        // 뷰가 화면에 나타날 때 테이블뷰 데이타 리로드
        fetchCars()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func fetchCars() {
        db.collection("cars").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            // 데이터를 순회하면서 Car 객체로 변환
            if let snapshot = snapshot {
                CarListManager.shared.cars = snapshot.documents.compactMap { document in
                    try? document.data(as: Car.self)
                }
                print("Fetched Cars: \(CarListManager.shared.cars)")
                self.tableView.reloadData()
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CarListManager.shared.allCars().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "carTableViewCell", for: indexPath) as! CarTableViewCell
        let car = CarListManager.shared.allCars()[indexPath.row]
        
        // 차량 이미지 비동기적으로 불러오기
        if let url = URL(string: car.image) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error loading image: \(error)")
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageViewCar.image = image
                    }
                }
            }.resume()
        }
        
        cell.labelName.text = car.name
        
        // 가격 정보 천단위 구분해서 보여주기
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let formattedNumber = formatter.string(from: NSNumber(value: car.price)) {
            cell.labelPrice.text = "\(formattedNumber)만원"
        }
        
        cell.labelYear.text = "\(car.year)년식"
        
        return cell
    }
}
