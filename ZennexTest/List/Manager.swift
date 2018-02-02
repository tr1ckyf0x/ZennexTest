//
//  Manager.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 27/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation

class Manager: EmployeeBase {
  var officeHours: String
  
  init(fullname: String, salary: Double, officeHours: String) {
    self.officeHours = officeHours
    super.init(fullname: fullname, salary: salary)
    super.employeeType = .manager
  }
}
