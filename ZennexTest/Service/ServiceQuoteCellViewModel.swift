//
//  ServiceQuoteCellViewModel.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 26/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import RxSwift

class ServiceQuoteCellViewModel {
  let id: Variable<String>
  let description: Variable<String>
  let time: Variable<String>
  let rating: Variable<String>
  
  init(quote: Quote) {
    id = Variable("#\(quote.id)")
    description = Variable(quote.description)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss dd.MM.yyyy"
    time = Variable(dateFormatter.string(from: quote.time))
    rating = Variable("Rating: \(quote.rating)")
  }
}
