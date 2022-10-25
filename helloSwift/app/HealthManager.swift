//
//  HealthManager.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/24.
//

import HealthKit

struct HealthManager {
    
    let store = HKHealthStore()
    
    /// 请求读取 HealthKit 权限
    func withPermission(completed:@escaping ()->Void) {
        //HKHealthStore.isHealthDataAvailable()
        let read: Set = [HKObjectType.quantityType(forIdentifier: .bodyMass)!]
        let write: Set = [HKObjectType.quantityType(forIdentifier: .bodyMass)!]
        store.requestAuthorization(toShare: write, read: read) { success, error in
            if success {
                completed()
            } else {
                print("without auth \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    /// 获取最近的体重数据
    func fetchWidgetData(completed:@escaping ([HKQuantitySample]?,Error?)->Void) {
        let quantityType: Set = [HKObjectType.quantityType(forIdentifier: .bodyMass)!]
        let startDate = Date(timeIntervalSinceNow: -30*24*60*60)
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate,
                                                    options: .strictStartDate)
        let sampleQuery = HKSampleQuery(sampleType: quantityType.first!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, res, error in
            DispatchQueue.main.async {
                completed(res as? [HKQuantitySample], error)
            }
        }
        store.execute(sampleQuery)
    }
    
    /// 写入新的体重数据
    func setBodyMass(_ value: Double, callback: @escaping (Bool,Error?)->Void) {
        let now = Date()
        guard let massType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return
        }
        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: value)
        let sample = HKQuantitySample(type: massType, quantity: quantity, start: now, end: now)
        store.save(sample) { success, error in
            if let error = error {
                print("error save data \(error.localizedDescription)")
                callback(false, error)
            } else {
                callback(true, nil)
            }
        }
    }
}
