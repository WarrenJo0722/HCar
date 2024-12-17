//
//  AddCarViewController.swift
//  HCar
//
//  Created by User on 12/17/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AddCarViewController: UIViewController, UINavigationControllerDelegate {
    let db = Firestore.firestore()
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldPrice: UITextField!
    @IBOutlet weak var textFieldYear: UITextField!
    @IBOutlet weak var buttonImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        // UIAlertController 생성
        let alertController = UIAlertController(title: "사진 추가", message: "사진을 가져올 방법을 선택하세요.", preferredStyle: .actionSheet)
        // 카메라 액션
        let cameraAction = UIAlertAction(title: "카메라", style: .default) { _ in
            self.openCamera()
        }
        // 앨범 액션
        let albumAction = UIAlertAction(title: "앨범", style: .default) { _ in
            self.openAlbum()
        }
        // 취소 액션
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        // 액션 추가
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        // 알러트 표시
        present(alertController, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        } else {
            showAlert("카메라를 사용할 수 없습니다.")
        }
    }
    
    func openAlbum() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        } else {
            showAlert("앨범을 사용할 수 없습니다.")
        }
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addCar(_ sender: UIBarButtonItem) {
        // 이미지 먼저 업로드(그 이후에 컬렉션에 Car 정보를 저장한다.)
        if let image = buttonImage.imageView?.image {
            uploadImage(image: image) { urlString in
                if let urlString = urlString {
                    print("Image uploaded successfully: \(urlString)")
                    // cars 컬렉션에 Car 정보 저장
                    let car = Car(name: self.textFieldName.text!, price: Int(self.textFieldPrice.text!)!, year: Int(self.textFieldYear.text!)!, image: urlString)
                    self.saveCar(car: car)
                } else {
                    print("Failed to upload image.")
                }
            }
        } else {
            print("Failed to load image.")
        }
    }
    
    // 이미지 업로드
    func uploadImage(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let storageRef = Storage.storage().reference().child("image/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error)")
                completion(nil)
            } else {
                storageRef.downloadURL { url, _ in
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    func saveCar(car: Car) {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(car)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            db.collection("cars").addDocument(data: jsonObject ?? [:]) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Car successfully written")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } catch {
            print("Error encoding car: \(error)")
        }
    }
}

extension AddCarViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            // 버튼에 이미지 설정
            setButtonImage(selectedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            // 원본 이미지를 버튼에 설정
            setButtonImage(originalImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func setButtonImage(_ image: UIImage) {
        // 버튼에 이미지 설정
        buttonImage.setImage(image, for: .normal)
        // 버튼 크기와 이미지 비율 유지
        buttonImage.imageView?.contentMode = .scaleAspectFill
        buttonImage.clipsToBounds = true
    }
}
