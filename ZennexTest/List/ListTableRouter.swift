//
//  ListTableRouter.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 28/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import UIKit

class ListTableRouter: Router {
  func route(to routeID: String, from context: UIViewController, parameters: Any?) {
    guard let route = ListViewController.Route(rawValue: routeID) else { return }
    switch route {
    case .edit:
      guard let employeeEditViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EmployeeEditViewController.identifier) as? EmployeeEditViewController
      else { return }
      let employeeEditViewModel: EmployeeEditViewModel
      if let employee = parameters as? EmployeeBase {
        employeeEditViewModel = EmployeeEditViewModel(employee: employee)
      } else {
        employeeEditViewModel = EmployeeEditViewModel()
      }
      employeeEditViewController.viewModel = employeeEditViewModel
//      employeeEditViewController.delegate = context as? EmployeeEditViewControllerDelegate
      context.navigationController?.pushViewController(employeeEditViewController, animated: true)
    }
  }
}
