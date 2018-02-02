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
  var model: EmployeeBase
  
  var fullname: Variable<String?>
  var salary: Variable<String?>
  var workplace: Variable<String?> = Variable(nil)
  var lunchTimeFrom: Variable<Date>
  var lunchTimeTo: Variable<Date>
  var officeHoursFrom: Variable<Date>
  var officeHoursTo: Variable<Date>
  var accountantTypeSelected: Variable<AccountantType> = Variable(.payroll)
  
  var fullnameValid: Observable<Bool>?
  var salaryValid: Observable<Bool>?
  var workplaceValid: Observable<Bool>?
  var allFieldsValid: Observable<Bool>?
  var selectedType: Variable<EmployeeType>
  
  init(employee: EmployeeBase) {
    let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm"
    let date = dateFormatter.date(from: "12:00")!
    lunchTimeFrom = Variable(date)
    lunchTimeTo = Variable(date)
    officeHoursFrom = Variable(date)
    officeHoursTo = Variable(date)
    model = employee
    selectedType = Variable(model.employeeType)
    fullname = Variable(model.fullname)
    salary = Variable("\(model.salary)")
    if let model = model as? Employee {
      workplace = Variable("\(model.workplace)")
      let lunchTime = model.lunchTime.components(separatedBy: "-")
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm"
      if
        let from = dateFormatter.date(from: lunchTime[0]),
        let to = dateFormatter.date(from: lunchTime[1]) {
        lunchTimeFrom = Variable(from)
        lunchTimeTo = Variable(to)
      }
    }
    if let model = model as? Accountant {
      accountantTypeSelected = Variable(model.type)
    }
    if let model = model as? Manager {
      let officeHours = model.officeHours.components(separatedBy: "-")
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm"
      if
        let from = dateFormatter.date(from: officeHours[0]),
        let to = dateFormatter.date(from: officeHours[1]) {
        officeHoursFrom = Variable(from)
        officeHoursTo = Variable(to)
      }
    }
    
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
  
  func getEmployee() -> EmployeeBase? {
    guard
      let fullname = self.fullname.value,
      let salaryString = self.salary.value,
      let salary = Double(salaryString)
      else { return nil }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    
    switch selectedType.value {
    case .employee, .accountant:
      guard
      let workplaceString = self.workplace.value,
      let workplace = Int(workplaceString)
        else { return nil }
      let lunchTimeFromString = dateFormatter.string(from: self.lunchTimeFrom.value)
      let lunchTimeToString = dateFormatter.string(from: self.lunchTimeTo.value)
      let lunchTime = "\(lunchTimeFromString)-\(lunchTimeToString)"
      if selectedType.value == .employee {
        return Employee(fullname: fullname, salary: salary, workplace: workplace, lunchTime: lunchTime)
      } else {
        return Accountant(fullname: fullname, salary: salary, workplace: workplace, lunchTime: lunchTime, type: accountantTypeSelected.value)
      }
    case .manager:
      let officeHoursFromString = dateFormatter.string(from: officeHoursFrom.value)
      let officeHoursToString = dateFormatter.string(from: officeHoursTo.value)
      let officeHours = "\(officeHoursFromString)-\(officeHoursToString)"
//      let officeHours = "\(officeHoursFromHour):\(officeHoursFromMinute)-\(officeHoursToHour):\(officeHoursToMinute)"
      return Manager(fullname: fullname, salary: salary, officeHours: officeHours)
    default: return nil
    }
  }
}
