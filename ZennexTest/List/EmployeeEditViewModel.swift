//
//  EmployeeEditViewModel.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 28/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import RxSwift

class EmployeeEditViewModel {
  var model: EmployeeBase?
  
  var fullname: Variable<String?> = Variable(nil)
  var salary: Variable<String?> = Variable(nil)
  var workplace: Variable<String?> = Variable(nil)
  var lunchtimeFrom: Variable<Date> = Variable(Utils.sharedInstance.hourDateFormatter.date(from: "12:00")!)
  var lunchtimeTo: Variable<Date> = Variable(Utils.sharedInstance.hourDateFormatter.date(from: "12:00")!)
  var officehoursFrom: Variable<Date> = Variable(Utils.sharedInstance.hourDateFormatter.date(from: "12:00")!)
  var officehoursTo: Variable<Date> = Variable(Utils.sharedInstance.hourDateFormatter.date(from: "12:00")!)
  var accountantTypeSelected: Variable<AccountantType> = Variable(.payroll)
  
  var fullnameValid: Observable<Bool>?
  var salaryValid: Observable<Bool>?
  var workplaceValid: Observable<Bool>?
  var allFieldsValid: Observable<Bool>?
  var selectedType: Variable<EmployeeType> = Variable(EmployeeType.employee)
  
  init() {
    fullnameValid = fullname.asObservable().map { value in
      // Проверяет строку == "Иванов Иван Иванович" || "Иванов" != "Иванов " || "Иванов Иван "
      checkBy(regexPattern: "^[:alpha:]+(\\s[:alpha:]+)*$", text: value)
    }
    salaryValid = salary.asObservable().map { value in
      // Проверяет строку == "1000" || "1000.0" || "1000.00"
      checkBy(regexPattern: "^[:digit:]+(\\.[:digit:]{1,2})?$", text: value)
    }
    workplaceValid = workplace.asObservable().map { value in
      // Проверяет строку == "1000"
      checkBy(regexPattern: "^[:digit:]+$", text: value)
    }
    allFieldsValid = Observable.combineLatest(fullnameValid!, salaryValid!, workplaceValid!) { fullname, salary, workplace in
      var result = fullname && salary
      if self.selectedType.value == .employee || self.selectedType.value == .accountant {
        result = result && workplace
      }
      return result
    }
  }
  
  convenience init(employee: EmployeeBase) {
    self.init()
    model = employee
    selectedType.value = employee.employeeType
    fullname.value = employee.fullname
    salary.value = "\(employee.salary)"
    if let model = model as? Employee {
      workplace.value = "\(model.workplace)"
      lunchtimeFrom.value = model.lunchtimeFrom
      lunchtimeTo.value = model.lunchtimeTo
    }
    if let model = model as? Accountant {
      accountantTypeSelected.value = model.accountantType
    }
    if let model = model as? Manager {
      officehoursFrom.value = model.officehoursFrom
      officehoursTo.value = model.officehoursTo
    }
  }
  
  func getEmployee() -> EmployeeBase {
      let fullname = self.fullname.value!
      let salary = Double(self.salary.value!)!
    
    switch selectedType.value {
    case .employee, .accountant:
      let workplace = Int(self.workplace.value!)!
      if selectedType.value == .employee {
        let employee = Employee(fullname: fullname, salary: salary, workplace: workplace, lunchTimeFrom: lunchtimeFrom.value, lunchtimeTo: lunchtimeTo.value)
        
        if let model = model {
          employee.id = model.id
          _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.delete(model)
        }
        _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.update(employee)
        
      } else {
        let accountant = Accountant(fullname: fullname, salary: salary, workplace: workplace, lunchTimeFrom: lunchtimeFrom.value, lunchtimeTo: lunchtimeTo.value, accountantType: accountantTypeSelected.value)
        if let model = model {
          accountant.id = model.id
          _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.delete(model)
        }
        _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.update(accountant)
      }
    case .manager:
      let manager = Manager(fullname: fullname, salary: salary, officehoursFrom: officehoursFrom.value, officehoursTo: officehoursTo.value)
      if let model = model {
        manager.id = model.id
        _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.delete(model)
      }
      _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.update(manager)
    default: fatalError("Selected unsupported EmployeeType in EmployeeEdit")
    }
    
    return EmployeeBase(fullname: "", salary: 0)
  }
}
