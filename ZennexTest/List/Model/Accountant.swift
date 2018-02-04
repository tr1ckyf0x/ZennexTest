//
//  Accountant.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 27/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import CoreData
import RxCoreData
import RxDataSources

enum AccountantType: String {
  case payroll = "Payroll"
  case materialAccounting = "Material Accounting"
}

class Accountant: Employee {
  private var accountantTypeValue: String
  var accountantType: AccountantType {
    get { return AccountantType(rawValue: accountantTypeValue)! }
    set { accountantTypeValue = newValue.rawValue }
  }
  
  init(fullname: String, salary: Double, workplace: Int, lunchTimeFrom: Date, lunchtimeTo: Date, accountantType: AccountantType) {
    self.accountantTypeValue = accountantType.rawValue
    super.init(fullname: fullname, salary: salary, workplace: workplace, lunchTimeFrom: lunchTimeFrom, lunchtimeTo: lunchtimeTo)
    self.employeeType = .accountant
  }
  
  override class var entityName: String { return "Accountant" }
  
  required init(entity: T) {
    accountantTypeValue = entity.value(forKey: "accountantTypeValue") as! String
    super.init(entity: entity)
  }
  
  override func update(_ entity: NSManagedObject) {
    entity.setValue(accountantTypeValue, forKey: "accountantTypeValue")
    super.update(entity)
  }
}
