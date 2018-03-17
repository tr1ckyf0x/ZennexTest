//
//  ServiceViewModel.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 26/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import Moya

// Добавить проверку доступности сети, повтор запроса при ошибке, вывод сообщения пользователю
class ServiceViewModel {
  var items = Variable([ServiceQuoteCellViewModel]())
  var isDownloading = Variable(true)
  let shouldShowErrorAlert = Variable(false)
  let bashService = MoyaProvider<BashService>()
  let disposeBag = DisposeBag()
  
  init() {
    updateData()
  }
  
  func updateData() {
    isDownloading.value = true
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    bashService.rx.request(.getQuotes)
      .map(BashResponse.self, atKeyPath: nil, using: decoder)
      .map { bashResponse in
        bashResponse.quotes.map { ServiceQuoteCellViewModel(quote: $0) }
      }
      .retry(3)
      .asObservable()
      .do(onError: { error in
        print(error)
        self.shouldShowErrorAlert.value = true
      })
      .do(onDispose: { print("bashServiceRequest disposed") })
      .catchErrorJustComplete()
      .do(onCompleted: {
        self.isDownloading.value = false
      })
      .bind(to: items)
      .disposed(by: disposeBag)
  }
}
