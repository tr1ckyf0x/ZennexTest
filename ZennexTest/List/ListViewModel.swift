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
  var items: Observable<[EmployeeSection]>
  
  init() {
    
    let employeeViewModels = CoreDataManager.sharedInstance.managedObjectContext.rx.entities(Employee.self)
      .map { employees in employees.filter {
        $0.employeeType == .employee
        }
        .map { employee in
        EmployeeCellViewModel(employee: employee)
        }
    }

    let accountantViewModels = CoreDataManager.sharedInstance.managedObjectContext.rx.entities(Accountant.self)
      .map { accountants in
        accountants.filter {
          $0.employeeType == .accountant
          }
          .map { accountant in
          AccountantCellViewModel(accountant: accountant)
        }
    }

    let managerViewModels = CoreDataManager.sharedInstance.managedObjectContext.rx.entities(Manager.self)
      .map { managers in
        managers.filter {
          $0.employeeType == .manager
          }
          .map { manager in
          ManagerCellViewModel(manager: manager)
        }
    }
    
    items = Observable.combineLatest(employeeViewModels, accountantViewModels, managerViewModels) { employees, accountants, managers in
      [EmployeeSection(type: .employee, items: employees), EmployeeSection(type: .accountant, items: accountants), EmployeeSection(type: .manager, items: managers)]
    }
//    items = Observable.combineLatest(employeeViewModels, accountantViewModels) { employees, accountants in
//      [EmployeeSection(type: .employee, items: employees), EmployeeSection(type: .accountant, items: accountants)]
//    }
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
  var pictureName: Variable<String> { get }
  var fullname: Variable<String> { get }
  var salary: Variable<String> { get }
}

class EmployeeCellViewModel: ListCellViewModel {
  var type: EmployeeType { return .employee }
  let model: EmployeeBase
  var pictureName: Variable<String>
  let fullname: Variable<String>
  let salary: Variable<String>
  let workplace: Variable<String>
  let lunchtime: Variable<String>
  
  
  init(employee: Employee) {
    model = employee
    pictureName = Variable("EmployeeIcon")
    fullname = Variable(employee.fullname)
    salary = Variable("Salary: \(employee.salary)")
    workplace = Variable("Workplace: \(employee.workplace)")
    let dateFormatter = Utils.sharedInstance.hourDateFormatter
    let lunchtimeFrom = dateFormatter.string(from: employee.lunchtimeFrom)
    let lunchtimeTo = dateFormatter.string(from: employee.lunchtimeTo)
    lunchtime = Variable("Lunchtime: \(lunchtimeFrom)-\(lunchtimeTo)")
  }
}

class AccountantCellViewModel: EmployeeCellViewModel {
  override var type: EmployeeType { return .accountant }
  let accountantType: Variable<String>
  
  init(accountant: Accountant) {
    accountantType = Variable("Type: \(accountant.accountantType.rawValue.capitalized)")
    super.init(employee: accountant as Employee)
    super.pictureName = Variable("AccountantIcon")
  }
}

class ManagerCellViewModel: ListCellViewModel {
  var type: EmployeeType { return .manager }
  var model: EmployeeBase
  var pictureName: Variable<String>
  let fullname: Variable<String>
  let salary: Variable<String>
  let officehours: Variable<String>
  
  init(manager: Manager) {
    model = manager
    pictureName = Variable("ManagerIcon")
    fullname = Variable(manager.fullname)
    salary = Variable("Salary: \(manager.salary)")
    let dateFormatter = Utils.sharedInstance.hourDateFormatter
    let officehoursFrom = dateFormatter.string(from: manager.officehoursFrom)
    let officehoursTo = dateFormatter.string(from: manager.officehoursTo)
    officehours = Variable("Office hours: \(officehoursFrom)-\(officehoursTo)")
  }
}
