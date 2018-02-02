//
//  EmployeeBase.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 27/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation

class EmployeeBase {
  var fullname: String
  var salary: Double
  var employeeType: EmployeeType = .employeeBase
  
  init(fullname: String, salary: Double) {
    self.fullname = fullname
    self.salary = salary
  }
}

enum EmployeeType: String {
  case employeeBase
  case employee
  case accountant
  case manager
}
