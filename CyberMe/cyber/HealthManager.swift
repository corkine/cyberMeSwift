//
//  HealthManager.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/24.
//

import HealthKit
import Combine

enum HealthServerKind: String, Hashable {
    case activeEnergy, basalEnergy, standTime, exerciseTime
}

typealias HMUploadData = (Double,Double,Int,Int,Double)

class HealthManager {
    
    let store = HKHealthStore()
    
    let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
    
    let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    
    let restEnergyType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
    
    let standTimeType = HKQuantityType.quantityType(forIdentifier: .appleStandTime)!
    
    let execTimeType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
    
    let mindful = HKCategoryType.categoryType(forIdentifier: .mindfulSession)!
    
    /// 请求读取 HealthKit 权限
    func withPermission(completed:@escaping ()->Void) {
        //HKHealthStore.isHealthDataAvailable()
        let read: Set = [bodyMassType, activeEnergyType, restEnergyType, standTimeType, execTimeType, mindful]
        let write: Set = [bodyMassType]
        store.requestAuthorization(toShare: write, read: read) { success, error in
            if success {
                completed()
            } else {
                print("without auth \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    enum SumType {
        case active, rest, stand, exec, mindful
    }
    
    var collect: Set<AnyCancellable> = []
    
    /// 获取当天的运动消耗、静息消耗、站立和运动时长
    func fetchWorkoutData(completed:@escaping (HMUploadData) -> Void) {
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let publisher = PassthroughSubject<(SumType, Double), Never>()
        store.execute(HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate) {
            query, data, error in
            if let data = data?.sumQuantity()?.doubleValue(for: .smallCalorie()) {
                publisher.send((SumType.active, data / 1000.0))
            } else if let error = error {
                print("error fetch activeEnergy \(error.localizedDescription)")
                publisher.send((SumType.active, 0))
            }
        })
        store.execute(HKStatisticsQuery(quantityType: restEnergyType, quantitySamplePredicate: predicate) {
            query, data, error in
            if let data = data?.sumQuantity()?.doubleValue(for: .smallCalorie()) {
                publisher.send((SumType.rest, data / 1000.0))
            } else if let error = error {
                print("error fetch restEnergy \(error.localizedDescription)")
                publisher.send((SumType.rest, 0))
            }
        })
        store.execute(HKStatisticsQuery(quantityType: standTimeType, quantitySamplePredicate: predicate) {
            query, data, error in
            if let data = data?.sumQuantity()?.doubleValue(for: .minute()) {
                publisher.send((SumType.stand, data))
            } else if let error = error {
                print("error fetch standTime \(error.localizedDescription)")
                publisher.send((SumType.stand, 0))
            }
        })
        store.execute(HKStatisticsQuery(quantityType: execTimeType, quantitySamplePredicate: predicate) {
            query, data, error in
            if let data = data?.sumQuantity()?.doubleValue(for: .minute()) {
                publisher.send((SumType.exec, data))
            } else if let error = error {
                print("error fetch execTime \(error.localizedDescription)")
                publisher.send((SumType.exec, 0))
            }
        })
        let startM = Calendar.current.startOfDay(for: Date())
        let endM = Calendar.current.date(byAdding: .day, value: 1, to: startM)
        let pre = HKQuery.predicateForSamples(withStart: startM, end: endM)
        let query = HKSampleQuery(sampleType: mindful, predicate: pre, limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) {
            query, res, err in
            if err == nil {
                var totalTime = 0.0
                if let results = res {
                    for result in results {
                        totalTime += result.endDate.timeIntervalSince(result.startDate)
                    }
                }
                publisher.send((SumType.mindful, totalTime / 60))
            } else {
                print("error fetch mindful \(String(describing: err?.localizedDescription))")
                publisher.send((SumType.mindful, 0))
            }
        }
        store.execute(query)
        publisher
            .collect(5)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .timeout(.seconds(10), scheduler: DispatchQueue.global(qos: .background))
            .sink { items in
                var active = 0.0
                var rest = 0.0
                var stand = 0
                var exec = 0
                var mindful = 0.0
                items.forEach { item in
                    switch item.0 {
                    case SumType.active: active = item.1
                    case SumType.rest: rest = item.1
                    case SumType.stand: stand = Int(item.1)
                    case SumType.exec: exec = Int(item.1)
                    case SumType.mindful: mindful = item.1
                    }
                }
                completed((active, rest, stand, exec, mindful))
                publisher.send(completion: .finished)
            }
            .store(in: &self.collect)
    }
    
    /// 获取最近的体重数据
    func fetchWidgetData(completed:@escaping ([HKQuantitySample]?,Error?)->Void) {
        let startDate = Date(timeIntervalSinceNow: -30*24*60*60)
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate,
                                                    options: .strictStartDate)
        let sampleQuery = HKSampleQuery(sampleType: bodyMassType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, res, error in
            DispatchQueue.main.async {
                completed(res as? [HKQuantitySample], error)
            }
        }
        store.execute(sampleQuery)
    }
    
    /// 写入新的体重数据
    func setBodyMass(_ value: Double, callback: @escaping (Bool,Error?)->Void) {
        let now = Date()
        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: value)
        let sample = HKQuantitySample(type: bodyMassType, quantity: quantity, start: now, end: now)
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
