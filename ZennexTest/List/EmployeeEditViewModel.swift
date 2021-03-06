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
  var maxEmployeesOrder: Variable<Int32> = Variable(0)
  var maxAccountantsOrder: Variable<Int32> = Variable(0)
  var maxManagersOrder: Variable<Int32> = Variable(0)
  
  var disposeBag = DisposeBag()
  
  init() {
    
    // Для проверки по регулярным выражениям следует использовать паттерн стратегия, времени не хватило.
    fullnameValid = fullname.asObservable().map { value in
      // Допустимые значение == "Иванов Иван Иванович" || "Иванов" != "Иванов " || "Иванов Иван "
      checkBy(regexPattern: "^[:alpha:]+(\\s[:alpha:]+)*$", text: value)
    }
    salaryValid = salary.asObservable().map { value in
      // Допустимые значение == "1000" || "1000.0" || "1000.00"
      checkBy(regexPattern: "^[:digit:]+(\\.[:digit:]{1,2})?$", text: value)
    }
    workplaceValid = workplace.asObservable().map { value in
      // Допустимые значение == "1000"
      checkBy(regexPattern: "^[:digit:]+$", text: value)
    }
    allFieldsValid = Observable.combineLatest(fullnameValid!, salaryValid!, workplaceValid!, selectedType.asObservable()) { fullname, salary, workplace, selectedType in
      var result = fullname && salary
      if selectedType == .employee || selectedType == .accountant {
        result = result && workplace
      }
      return result
    }
    
    CoreDataManager.sharedInstance.managedObjectContext.rx.entities(Employee.self)
      .map { employees in
        employees.max(by: { left, right in left.order < right.order })?.order
      }
      .unwrap()
      .bind(to: maxEmployeesOrder)
      .disposed(by: disposeBag)
    CoreDataManager.sharedInstance.managedObjectContext.rx.entities(Accountant.self)
      .map { accountants in
        accountants.max(by: { left, right in left.order < right.order })?.order
      }
      .unwrap()
      .bind(to: maxAccountantsOrder)
      .disposed(by: disposeBag)
    CoreDataManager.sharedInstance.managedObjectContext.rx.entities(Manager.self)
      .map { managers in
        managers.max(by: { left, right in left.order < right.order })?.order
      }
      .unwrap()
      .bind(to: maxManagersOrder)
      .disposed(by: disposeBag)
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
  
  func saveEmployee() {
    let fullname = self.fullname.value!
    let salary = Double(self.salary.value!)!
    var employee: EmployeeBase
    
    switch selectedType.value {
    case .employee, .accountant:
      let workplace = Int(self.workplace.value!)!
      if selectedType.value == .employee {
        employee = Employee(fullname: fullname, salary: salary, workplace: workplace, lunchTimeFrom: lunchtimeFrom.value, lunchtimeTo: lunchtimeTo.value)
        employee.order = maxEmployeesOrder.value + 1
      } else {
        employee = Accountant(fullname: fullname, salary: salary, workplace: workplace, lunchTimeFrom: lunchtimeFrom.value, lunchtimeTo: lunchtimeTo.value, accountantType: accountantTypeSelected.value)
        employee.order = maxAccountantsOrder.value + 1
      }
    case .manager:
      employee = Manager(fullname: fullname, salary: salary, officehoursFrom: officehoursFrom.value, officehoursTo: officehoursTo.value)
      employee.order = maxManagersOrder.value + 1
    default: return
    }
    
    if let model = model {
      if model.employeeType == employee.employeeType {
        employee.order = model.order
      }
      _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.delete(model)
    }
    
    switch employee.employeeType {
    case .employee: _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.update(employee as! Employee)
    case .accountant: _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.update(employee as! Accountant)
    case .manager: _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.update(employee as! Manager)
    default: break
    }
  }
}
