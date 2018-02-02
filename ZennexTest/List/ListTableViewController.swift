//
//  ListTableViewController.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 28/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
  
  var viewModel: ListViewModel?
  var router: Router = ListTableRouter()
  var isEditingEmployee = false
  var editingEmployeeIndexPath = IndexPath()
  
  enum Route: String {
    case edit
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    isEditingEmployee = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = true
    self.navigationItem.leftBarButtonItem = self.editButtonItem
    let checkBarButtonItem = UIBarButtonItem(title: "Check", style: .plain, target: self, action: #selector(checkButtonTapped))
    let sortBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortButtonTapped))
    let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    navigationItem.rightBarButtonItems = [addBarButtonItem, sortBarButtonItem, checkBarButtonItem]
    
    let employeeCellNib = UINib(nibName: EmployeeCell.identifier, bundle: nil)
    tableView.register(employeeCellNib, forCellReuseIdentifier: EmployeeCell.identifier)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 150
    
    viewModel = ListViewModel()
  }
  
  @objc func checkButtonTapped() {
    viewModel?.items[0].items.forEach { item in print(item.fullname.value) }
  }
  @objc func sortButtonTapped() {
    guard let viewModel = viewModel else { return }
    for i in 0 ..< viewModel.items.count {
      viewModel.items[i].items = viewModel.items[i].items.sorted { left, right in left.fullname.value < right.fullname.value }
    }
    tableView.reloadData()
  }
  @objc func addButtonTapped() {
    let model = Employee(fullname: "", salary: 0, workplace: 0, lunchTime: "12:00-12:00")
    router.route(to: Route.edit.rawValue, from: self, parameters: model)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel?.items.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel?.items[section].items.count ?? 0
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: EmployeeCell.identifier, for: indexPath) as? EmployeeCell else { return UITableViewCell() }
    cell.viewModel = viewModel?.items[indexPath.section].items[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let header = viewModel?.items[section].header {
      return header + "s"
    }
    return "Unnamed section"
  }
  
  
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      viewModel?.items[indexPath.section].items.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
  
  
  
  // Override to support rearranging the table view.
  override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    guard
      let fromItem = viewModel?.items[fromIndexPath.section].items[fromIndexPath.row],
      let toItem = viewModel?.items[to.section].items[to.row]
      else { return }
    viewModel?.items[fromIndexPath.section].items[fromIndexPath.row] = toItem
    viewModel?.items[to.section].items[to.row] = fromItem
  }
  
  override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
    guard sourceIndexPath.section == proposedDestinationIndexPath.section else { return sourceIndexPath }
    return proposedDestinationIndexPath
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = viewModel?.items[indexPath.section].items[indexPath.row].model
    isEditingEmployee = true
    editingEmployeeIndexPath = indexPath
    router.route(to: Route.edit.rawValue, from: self, parameters: model)
    
  }
  
}

extension ListTableViewController: Identifiable {
  static var identifier: String { return "ListTableViewController" }
}

extension ListTableViewController: EmployeeEditViewControllerDelegate {
  func employeeEditViewController(_ viewController: EmployeeEditViewController, didEditEmployee employee: EmployeeBase) {
    var newViewModel: ListCellViewModel
    switch employee.employeeType {
      // Заменить на фабрику
    case .employee: newViewModel = EmployeeCellViewModel(employee: employee as! Employee)
    case .accountant: newViewModel = AccountantCellViewModel(accountant: employee as! Accountant)
    case .manager: newViewModel = ManagerCellViewModel(manager: employee as! Manager)
    default: return
    }
    guard let section = (viewModel?.items.index { $0.type == employee.employeeType }) else { return }
    
    if isEditingEmployee == true {
      if editingEmployeeIndexPath.section == section {
        viewModel?.items[section].items[editingEmployeeIndexPath.row] = newViewModel
      } else {
        viewModel?.items[editingEmployeeIndexPath.section].items.remove(at: editingEmployeeIndexPath.row)
        viewModel?.items[section].items.append(newViewModel)
      }
    } else {
      // добавить в конец
      viewModel?.items[section].items.append(newViewModel)
    }
    tableView.reloadData()
  }
}
