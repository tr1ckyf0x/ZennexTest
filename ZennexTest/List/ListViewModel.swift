//
//  ViewModel.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 27/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class ListViewModel {
  var items: [EmployeeSection]
  
  init() {
    let employeeCell = EmployeeCellViewModel(employee: Employee(fullname: "Владислав Лисянский", salary: 30000, workplace: 1, lunchTime: "10:15-12:45"))
    let anotherEmployeeCell = EmployeeCellViewModel(employee: Employee(fullname: "Another man", salary: 99999, workplace: 42, lunchTime: "13:30-17:30"))
    let accountantCell = AccountantCellViewModel(accountant: Accountant(fullname: "Иванов Иван", salary: 15000, workplace: 15, lunchTime: "18:00-19:00", type: .materialAccounting))
    let managerCell = ManagerCellViewModel(manager: Manager(fullname: "Акулов Антон", salary: 34000, officeHours: "10:00-18:00"))
    
    let employeesSection = EmployeeSection(type: .employee, items: [employeeCell, anotherEmployeeCell])
    let accountantsSection = EmployeeSection(type: .accountant, items: [accountantCell])
    let managersSection = EmployeeSection(type: .manager, items: [managerCell])
    
    items = [employeesSection, accountantsSection, managersSection]
  }
  
}

struct EmployeeSection: SectionModelType {
  var type: EmployeeType
  var header: String { return type.rawValue.capitalized }
  var items: [Item]
}

extension EmployeeSection  {
  typealias Item = ListCellViewModel
  
  init(original: EmployeeSection, items: [EmployeeSection.Item]) {
    self = original
    self.items = items
  }

}

protocol ListCellViewModel {
  var model: EmployeeBase { get }
  var type: EmployeeType { get }
  var pictureName: Variable<String> { get set }
  var fullname: Variable<String> { get set }
  var salary: Variable<String> { get set }
}

class EmployeeCellViewModel: ListCellViewModel {
  var type: EmployeeType { return .employee }
  var model: EmployeeBase
  var pictureName: Variable<String>
  var fullname: Variable<String>
  var salary: Variable<String>
  var workplace: Variable<String>
  var lunchTime: Variable<String>
  
  
  init(employee: Employee) {
    model = employee
    pictureName = Variable("EmployeeIcon")
    fullname = Variable(employee.fullname)
    salary = Variable("\(employee.salary)")
    workplace = Variable("\(employee.workplace)")
    lunchTime = Variable(employee.lunchTime)
  }
}

class AccountantCellViewModel: EmployeeCellViewModel {
  override var type: EmployeeType { return .accountant }
  var accountantType: Variable<AccountantType>
  
  init(accountant: Accountant) {
    accountantType = Variable(accountant.type)
    super.init(employee: accountant as Employee)
    super.pictureName = Variable("AccountantIcon")
  }
}

class ManagerCellViewModel: ListCellViewModel {
  var type: EmployeeType { return .manager }
  var model: EmployeeBase
  var pictureName: Variable<String>
  var fullname: Variable<String>
  var salary: Variable<String>
  var officeHours: Variable<String>
  
  init(manager: Manager) {
    model = manager
    pictureName = Variable("ManagerIcon")
    fullname = Variable(manager.fullname)
    salary = Variable("\(manager.salary)")
    officeHours = Variable(manager.officeHours)
  }
}
