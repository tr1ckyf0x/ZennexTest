//
//  EmployeeCell.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 27/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EmployeeCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var iconImage: UIImageView!
  var viewModel: ListCellViewModel? {
    didSet {
      guard let viewModel = viewModel else { return }
      let salaryLabel = UILabel()
      stackView.addArrangedSubview(salaryLabel)
      viewModel
        .pictureName
        .asObservable()
        .map { UIImage(named: $0) }
        .bind(to: iconImage.rx.image)
        .disposed(by: reuseBag)
      viewModel
        .fullname
        .asObservable()
        .bind(to: nameLabel.rx.text)
        .disposed(by: reuseBag)
      viewModel
        .salary
        .asObservable()
//        .map { "Salary: \($0)" }
        .bind(to: salaryLabel.rx.text)
        .disposed(by: reuseBag)
      
      switch viewModel.type {
      case .employee, .accountant:
        let employeeCellViewModel = viewModel as! EmployeeCellViewModel
        let workplaceLabel = UILabel()
        let lunchTimeLabel = UILabel()
        stackView.addArrangedSubview(workplaceLabel)
        stackView.addArrangedSubview(lunchTimeLabel)
        employeeCellViewModel
          .workplace
          .asObservable()
//          .map { "Workplace: \($0)" }
          .bind(to: workplaceLabel.rx.text)
          .disposed(by: reuseBag)
        employeeCellViewModel
          .lunchtime
          .asObservable()
//          .map { "Lunch time: \($0)" }
          .bind(to: lunchTimeLabel.rx.text)
          .disposed(by: reuseBag)
        
        guard viewModel.type == .accountant else { break }
        let accountantCellViewModel = viewModel as! AccountantCellViewModel
        let accountantTypeLabel = UILabel()
        stackView.addArrangedSubview(accountantTypeLabel)
        accountantCellViewModel
          .accountantType
          .asObservable()
//          .map { "Type: \($0.rawValue.capitalized)" }
          .bind(to: accountantTypeLabel.rx.text)
          .disposed(by: reuseBag)
        
      case .manager:
        let managerCellViewModel = viewModel as! ManagerCellViewModel
        let officeHoursLabel = UILabel()
        stackView.addArrangedSubview(officeHoursLabel)
        managerCellViewModel
          .officehours
          .asObservable()
//          .map { "Office hours: \($0)" }
          .bind(to: officeHoursLabel.rx.text)
          .disposed(by: reuseBag)
        
      default: break
      }
    }
  }
  var reuseBag = DisposeBag()
  
  override func prepareForReuse() {
    super.prepareForReuse()
    reuseBag = DisposeBag()
    stackView.arrangedSubviews.forEach {
      stackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    
  }
  
}

extension EmployeeCell: Identifiable {
  static var identifier: String { return "EmployeeCell" }
}
