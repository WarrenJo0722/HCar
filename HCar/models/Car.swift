//
//  Car.swift
//  HCar
//
//  Created by User on 12/17/24.
//

import Foundation
import UIKit

struct Car: Codable {
    var id: String?
    let name: String
    var price: Int
    let year: Int // 연식
    let image: String
    let details: String // 자세한 설명
    let userId: String // 판매자
    var isSale: Bool? = false
}
