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
  var viewModel: ServiceViewModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel = ServiceViewModel()
    viewModel?
      .isDownloading
      .asObservable()
      .bind(to: activityIndicator.rx.isAnimating)
      .disposed(by: rx.disposeBag)
    let quoteCellNib = UINib(nibName: QuoteCell.identifier, bundle: nil)
    tableView.register(quoteCellNib, forCellReuseIdentifier: QuoteCell.identifier)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 150
    
    viewModel?
      .items
      .asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: QuoteCell.identifier, cellType: QuoteCell.self)) { index, viewModel, cell in
        cell.viewModel = viewModel
      }
      .disposed(by: rx.disposeBag)
    
  }
  
}

extension ServiceTableViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension ServiceTableViewController: Identifiable {
  static var identifier: String { return "ServiceTableViewController" }
}
