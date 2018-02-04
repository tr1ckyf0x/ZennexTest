//
//  Manager.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 27/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import CoreData
import RxCoreData
import RxDataSources

class Manager: EmployeeBase {
  var officehoursFrom: Date
  var officehoursTo: Date

  init(fullname: String, salary: Double, officehoursFrom: Date, officehoursTo: Date) {
    self.officehoursFrom = officehoursFrom
    self.officehoursTo = officehoursTo
    super.init(fullname: fullname, salary: salary)
//    super.employeeType = .manager
    self.employeeType = .manager
  }
  
  override class var entityName: String { return "Manager" }
  
  required init(entity: T) {
    
    officehoursFrom = entity.value(forKey: "officehoursFrom") as! Date
    officehoursTo = entity.value(forKey: "officehoursTo") as! Date
    super.init(entity: entity)
  }
  
  override func update(_ entity: NSManagedObject) {
    entity.setValue(officehoursFrom, forKey: "officehoursFrom")
    entity.setValue(officehoursTo, forKey: "officehoursTo")
    super.update(entity)
  }
}
