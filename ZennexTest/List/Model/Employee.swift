//
//  Employee.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 27/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import CoreData
import RxCoreData
import RxDataSources

class Employee: EmployeeBase {
  var workplace: Int32
  var lunchtimeFrom: Date
  var lunchtimeTo: Date
  
  init(fullname: String, salary: Double, workplace: Int, lunchTimeFrom: Date, lunchtimeTo: Date) {
    self.workplace = Int32(workplace)
    self.lunchtimeFrom = lunchTimeFrom
    self.lunchtimeTo = lunchtimeTo
    super.init(fullname: fullname, salary: salary)
    self.employeeType = .employee
  }
  
  override class var entityName: String { return "Employee" }
  
  required init(entity: T) {
    workplace = entity.value(forKey: "workplace") as! Int32
    lunchtimeFrom = entity.value(forKey: "lunchtimeFrom") as! Date
    lunchtimeTo = entity.value(forKey: "lunchtimeTo") as! Date
    super.init(entity: entity)
  }
  
  override func update(_ entity: NSManagedObject) {
    entity.setValue(workplace, forKey: "workplace")
    entity.setValue(lunchtimeFrom, forKey: "lunchtimeFrom")
    entity.setValue(lunchtimeTo, forKey: "lunchtimeTo")
    super.update(entity)
  }
}
