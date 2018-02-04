//
//  EmployeeBase.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 27/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import CoreData
import RxCoreData
import RxDataSources

enum EmployeeType: String {
  case employeeBase
  case employee
  case accountant
  case manager
}


class EmployeeBase: Persistable {
  var id: String
  var fullname: String
  var salary: Double
  private var employeeTypeValue: String
  var employeeType: EmployeeType {
    get { return EmployeeType(rawValue: employeeTypeValue)! }
    set { employeeTypeValue = newValue.rawValue }
  }
  init(fullname: String, salary: Double) {
    self.id = UUID().uuidString
    self.fullname = fullname
    self.salary = salary
    self.employeeTypeValue = EmployeeType.employeeBase.rawValue
  }
  
  typealias T = NSManagedObject
//  static var entityName: String { return "EmployeeBase" }
  class var entityName: String { return "EmployeeBase" }
  
//  static var primaryAttributeName: String { return "fullname" }
  class var primaryAttributeName: String { return "id" }
  
  required init(entity: T) {
    id = entity.value(forKey: "id") as! String
    fullname = entity.value(forKey: "fullname") as! String
    salary = entity.value(forKey: "salary") as! Double
    employeeTypeValue = entity.value(forKey: "employeeTypeValue") as! String
  }
  
  func update(_ entity: NSManagedObject) {
    entity.setValue(id, forKey: "id")
    entity.setValue(fullname, forKey: "fullname")
    entity.setValue(salary, forKey: "salary")
    entity.setValue(employeeTypeValue, forKey: "employeeTypeValue")
    
    do {
      try entity.managedObjectContext?.save()
    } catch let e {
      print(e)
    }
  }
}


extension EmployeeBase: Equatable {
  static func ==(lhs: EmployeeBase, rhs: EmployeeBase) -> Bool {
    return lhs.id == rhs.id
  }
}

extension EmployeeBase: IdentifiableType {
  typealias Identity = String
  
  var identity: Identity { return id }
}
