//
//  QuoteCell.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 26/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class QuoteCell: UITableViewCell {
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var idLabel: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var ratingLabel: UILabel!
  
  var reuseBag = DisposeBag()
  var viewModel: ServiceQuoteCellViewModel? {
    didSet {
      viewModel?
        .description
        .asObservable()
        .bind(to: descriptionTextView.rx.text)
        .disposed(by: reuseBag)
      
      viewModel?
      .id
      .asObservable()
      .bind(to: idLabel.rx.text)
      .disposed(by: reuseBag)
      
      viewModel?
      .rating
      .asObservable()
      .bind(to: ratingLabel.rx.text)
      .disposed(by: reuseBag)
      
      viewModel?
      .time
      .asObservable()
      .bind(to: timeLabel.rx.text)
      .disposed(by: reuseBag)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    reuseBag = DisposeBag()
  }
  
  
}

extension QuoteCell: Identifiable {
  static var identifier: String { return "QuoteCell" }
}
