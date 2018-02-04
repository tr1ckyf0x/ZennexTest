//
//  ListViewController.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 03/02/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxCoreData
import RxSwiftExt
import NSObject_Rx

class ListViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var sortButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: nil)
  var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
  var viewModel: ListViewModel?
  var router: Router = ListTableRouter()
  let dataSource = RxTableViewSectionedReloadDataSource<EmployeeSection>(
    configureCell: { datasource, tableView, indexPath, item in
      guard let cell = tableView.dequeueReusableCell(withIdentifier: EmployeeCell.identifier, for: indexPath) as? EmployeeCell else { return UITableViewCell() }
      cell.viewModel = item
      return cell
  },
    titleForHeaderInSection: { dataSource, index in
      return dataSource.sectionModels[index].header
  },
    canEditRowAtIndexPath: { _,_ in return true },
    canMoveRowAtIndexPath: { _,_ in return true })
  
  enum Route: String {
    case edit
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupBarItems()
    setupViewModel()
  }
  
  func setupTableView() {
    let employeeCellNib = UINib(nibName: EmployeeCell.identifier, bundle: nil)
    tableView.register(employeeCellNib, forCellReuseIdentifier: EmployeeCell.identifier)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 150
    tableView.rx.itemSelected
      .do(onNext: { indexPath in
        self.tableView.deselectRow(at: indexPath, animated: true)
      })
      .map { indexPath -> ListCellViewModel in
        return try self.tableView.rx.model(at: indexPath)
      }
      .subscribe(onNext: { viewModel in
        self.router.route(to: Route.edit.rawValue, from: self, parameters: viewModel.model)
        print("Selected \(viewModel.fullname.value)")
      })
      .disposed(by: rx.disposeBag)
    tableView.rx.itemDeleted
      .map { indexPath -> ListCellViewModel in
        return try self.tableView.rx.model(at: indexPath)
      }
      .subscribe(onNext: { viewModel in
        _ = try? CoreDataManager.sharedInstance.managedObjectContext.rx.delete(viewModel.model)
      })
    .disposed(by: rx.disposeBag)
  }
  
  func setupBarItems() {
    navigationItem.leftBarButtonItem = self.editButtonItem
    navigationItem.rightBarButtonItems = [addButtonItem, sortButtonItem]
    editButtonItem.rx.tap.subscribe(onNext: { event in
      self.tableView.setEditing(!self.tableView.isEditing, animated: true)
      self.editButtonItem.title = self.tableView.isEditing ? "Done" : "Edit"
    })
      .disposed(by: rx.disposeBag)
    sortButtonItem.rx.tap.subscribe(onNext: { event in
      print("Sort")
    })
      .disposed(by: rx.disposeBag)
    addButtonItem.rx.tap.subscribe(onNext: { event in
      self.router.route(to: Route.edit.rawValue, from: self, parameters: nil)
      })
      .disposed(by: rx.disposeBag)
  }
  
  func setupViewModel() {
    viewModel = ListViewModel()
    
    viewModel?.items.bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: rx.disposeBag)
  }
  
}

extension ListViewController: Identifiable {
  static var identifier: String { return "ListViewController" }
}
