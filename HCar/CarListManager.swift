//
//  CarListManager.swift
//  HCar
//
//  Created by User on 12/17/24.
//

import Foundation

class CarListManager {
    static let shared = CarListManager() // 싱글톤 패턴
    private init() {}
    
    public var cars: [Car] = [
//        Car(name: "투싼 하이브리드 1.6 터보", price: 1900, year: 2020, imageName: "tucson"/*, image: nil*/),
//        Car(name: "제네시스 G80 가솔린 터보 2.5", price: 4200, year: 2022, imageName: "g80"/*, image: nil*/),
//        Car(name: "더 뉴 벨로스터 1.6 PYL", price: 680, year: 2015, imageName: "veloster"/*, image: nil*/),
//        Car(name: "더 뉴 아반떼 가솔린 1.6 스마트", price: 880, year: 2019, imageName: "avante"/*, image: nil*/)
    ]
    
    func allCars() -> [Car] {
        return cars
    }
    
    func setAllCars(cars: [Car]) {
        self.cars = cars
    }
//
//    func addCar(_ car: Car) {
//        cars.append(car)
//    }
}
