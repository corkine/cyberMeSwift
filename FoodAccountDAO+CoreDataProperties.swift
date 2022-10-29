//
//  FoodAccountDAO+CoreDataProperties.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/29.
//
//

import Foundation
import CoreData


extension FoodAccountDAO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodAccountDAO> {
        return NSFetchRequest<FoodAccountDAO>(entityName: "FoodAccountDAO")
    }

    @NSManaged public var name: String?
    @NSManaged public var image: String?
    @NSManaged public var note: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var calories: Double
    @NSManaged public var category: String?
    @NSManaged public var solved: Bool

}

extension FoodAccountDAO : Identifiable {

}
