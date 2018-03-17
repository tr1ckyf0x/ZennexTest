//
//  ServiceTableViewController.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 26/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxDataSources
import NSObject_Rx

class ServiceTableViewController: UIViewController {
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var tableView: UITableView!
  private let refreshControl = UIRefreshControl()
  var viewModel: ServiceViewModel?
  
  @objc private func refreshData(_ sender: Any) {
    // Fetch Weather Data
    viewModel?.updateData()
    refreshControl.endRefreshing()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel = ServiceViewModel()
    viewModel?
      .isDownloading
      .asObservable()
      .take(2)
      .bind(to: activityIndicator.rx.isAnimating)
      .disposed(by: rx.disposeBag)
    
    viewModel?
    .isDownloading
    .asObservable()
      .filter { value in !value }
    .subscribe(onNext: { _ in self.refreshControl.endRefreshing() })
    .disposed(by: rx.disposeBag)
    let quoteCellNib = UINib(nibName: QuoteCell.identifier, bundle: nil)
    tableView.register(quoteCellNib, forCellReuseIdentifier: QuoteCell.identifier)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 150
    tableView.allowsSelection = false
    tableView.refreshControl = refreshControl
    refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    
    viewModel?
      .items
      .asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: QuoteCell.identifier, cellType: QuoteCell.self)) { index, viewModel, cell in
        cell.viewModel = viewModel
      }
      .disposed(by: rx.disposeBag)
    
    viewModel?
    .shouldShowErrorAlert
    .asObservable()
    .filter { value in value }
      .subscribe(onNext: { _ in
        let alert = UIAlertController(title: "Error occured", message: "Can not download data", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: { self.viewModel?.shouldShowErrorAlert.value = false })
      })
    .disposed(by: rx.disposeBag)
  }
}

extension ServiceTableViewController: Identifiable {
  static var identifier: String { return "ServiceTableViewController" }
}
