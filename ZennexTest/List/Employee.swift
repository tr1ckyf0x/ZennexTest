//
//  Employee.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 27/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation

class Employee: EmployeeBase {
  var workplace: Int
  var lunchTime: String
  
  init(fullname: String, salary: Double, workplace: Int, lunchTime: String) {
    self.workplace = workplace
    self.lunchTime = lunchTime
    super.init(fullname: fullname, salary: salary)
    super.employeeType = .employee
  }
}
