//
//  EmployeeEditViewController.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 28/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt

class EmployeeEditViewController: UIViewController {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var employeeTypeSegmentedControl: UISegmentedControl!
  @IBOutlet weak var fullnameTextField: UITextField!
  @IBOutlet weak var salaryTextField: UITextField!
  @IBOutlet weak var workplaceTextField: UITextField!
  @IBOutlet weak var lunchTimeStackView: UIStackView!
  @IBOutlet weak var lunchTimeFromDatePicker: UIDatePicker!
  @IBOutlet weak var lunchTimeToDatePicker: UIDatePicker!
  @IBOutlet weak var officeHoursStackView: UIStackView!
  @IBOutlet weak var officeHoursFromDatePicker: UIDatePicker!
  @IBOutlet weak var officeHoursToDatePicker: UIDatePicker!
  @IBOutlet weak var accountantTypeSegmentedControl: UISegmentedControl!
  
  var commonViews = Set<UIView>()
  var employeeViews = Set<UIView>()
  var accountantViews = Set<UIView>()
  var managerViews = Set<UIView>()
  var viewModel: EmployeeEditViewModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    commonViews = [employeeTypeSegmentedControl, fullnameTextField, salaryTextField]
    employeeViews = [workplaceTextField, lunchTimeStackView]
    accountantViews = [accountantTypeSegmentedControl]
    managerViews = [officeHoursStackView]
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: nil)
    navigationItem.rightBarButtonItem?.rx.tap.subscribe(onNext: {
      self.viewModel?.saveEmployee()
      self.navigationController?.popViewController(animated: true)
    })
    .disposed(by: rx.disposeBag)
    if let type = viewModel?.selectedType {
      setupStackViews(forEmployeeType: type.value)
    }
    
    if let viewModel = viewModel {
      (fullnameTextField.rx.text <-> viewModel.fullname).disposed(by: rx.disposeBag)
      (salaryTextField.rx.text <-> viewModel.salary).disposed(by: rx.disposeBag)
      (workplaceTextField.rx.text <-> viewModel.workplace).disposed(by: rx.disposeBag)
      (lunchTimeFromDatePicker.rx.date <-> viewModel.lunchtimeFrom).disposed(by: rx.disposeBag)
      (lunchTimeToDatePicker.rx.date <-> viewModel.lunchtimeTo).disposed(by: rx.disposeBag)
      (officeHoursFromDatePicker.rx.date <-> viewModel.officehoursFrom).disposed(by: rx.disposeBag)
      (officeHoursToDatePicker.rx.date <-> viewModel.officehoursTo).disposed(by: rx.disposeBag)
      
      viewModel.fullnameValid?
        .subscribe(onNext: { value in
          self.setFieldColor(field: self.fullnameTextField, isCorrect: value)
        })
        .disposed(by: rx.disposeBag)
      viewModel.salaryValid?
        .subscribe(onNext: { value in
          self.setFieldColor(field: self.salaryTextField, isCorrect: value)
        })
        .disposed(by: rx.disposeBag)
      viewModel.workplaceValid?
        .subscribe(onNext: { value in
          self.setFieldColor(field: self.workplaceTextField, isCorrect: value)
        })
        .disposed(by: rx.disposeBag)
      viewModel.allFieldsValid?
        .bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled)
        .disposed(by: rx.disposeBag)
      
      viewModel.selectedType.asObservable().map { value -> Int? in
        let typeString = value.rawValue.capitalized
        for i in 0 ..< self.employeeTypeSegmentedControl.numberOfSegments {
          if self.employeeTypeSegmentedControl.titleForSegment(at: i) == typeString {
            return i
          }
        }
        return nil
      }
      .unwrap()
      .bind(to: employeeTypeSegmentedControl.rx.selectedSegmentIndex)
      .disposed(by: rx.disposeBag)
      
      employeeTypeSegmentedControl.rx.selectedSegmentIndex
        .map { selectedIndex -> EmployeeType? in
          guard
            let title = self.employeeTypeSegmentedControl.titleForSegment(at: selectedIndex)?.lowercased(),
            let type = EmployeeType(rawValue: title)
            else { return nil }
          return type
        }
        .unwrap()
        .bind(to: viewModel.selectedType)
        .disposed(by: rx.disposeBag)
      
      viewModel.selectedType.asObservable().subscribe(onNext: { value in
        self.setupStackViews(forEmployeeType: value)
      })
      .disposed(by: rx.disposeBag)
      
      viewModel.accountantTypeSelected.asObservable().map { value -> Int? in
        let typeString = value.rawValue.capitalized
        for i in 0 ..< self.accountantTypeSegmentedControl.numberOfSegments {
          if self.accountantTypeSegmentedControl.titleForSegment(at: i) == typeString {
            return i
          }
        }
        return nil
      }
      .unwrap()
      .bind(to: accountantTypeSegmentedControl.rx.selectedSegmentIndex)
      .disposed(by: rx.disposeBag)
      
      accountantTypeSegmentedControl.rx.value.map { value -> AccountantType? in
        guard
        let title = self.accountantTypeSegmentedControl.titleForSegment(at: value),
        let type = AccountantType(rawValue: title)
          else { return nil }
        return type
      }
      .unwrap()
      .bind(to: viewModel.accountantTypeSelected)
      .disposed(by: rx.disposeBag)
    }
  }
  
  func setFieldColor(field: UITextField, isCorrect: Bool) {
    field.textColor = isCorrect ? UIColor.black : UIColor.red
  }
  
  func setupStackViews(forEmployeeType type: EmployeeType) {
    
    // Заменить на биндинги к viewModel?.selectedType
    
    func showNeededViews(set: Set<UIView>) {
      Set(stackView.arrangedSubviews).subtracting(set).forEach { view in
        view.isHidden = true
      }
      
      set.forEach { view in
        view.isHidden = false
      }
    }
    
    switch type {
    case .employee:
      let neededViews = commonViews.union(employeeViews)
      showNeededViews(set: neededViews)
    case .accountant:
      let neededViews = commonViews.union(employeeViews.union(accountantViews))
      showNeededViews(set: neededViews)
    case .manager:
      let neededViews = commonViews.union(managerViews)
      showNeededViews(set: neededViews)
    default: break
    }
  }
}

extension EmployeeEditViewController: Identifiable {
  static var identifier: String { return "EmployeeEditViewController" }
}
