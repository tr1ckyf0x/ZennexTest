//
//  Accountant.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 27/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation

enum AccountantType: String {
  case payroll = "Payroll"
  case materialAccounting = "Material Accounting"
}

class Accountant: Employee {
  var type: AccountantType
  init(fullname: String, salary: Double, workplace: Int, lunchTime: String, type: AccountantType) {
    self.type = type
    super.init(fullname: fullname, salary: salary, workplace: workplace, lunchTime: lunchTime)
    super.employeeType = .accountant
  }
}
