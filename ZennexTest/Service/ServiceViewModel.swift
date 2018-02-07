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

// Следует выделить API в класс с енумом ендпонитнов, и функциями, возвращающими объекты
// Времени не хватило
// Также добавить проверку доступности сети, повтор запроса при ошибке, вывод сообщения пользователю
class ServiceViewModel {
  var items = Variable([ServiceQuoteCellViewModel]())
  var isDownloading = Variable(true)
  let bashService = MoyaProvider<BashService>()
  let disposeBag = DisposeBag()
  
  init() {
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    bashService.rx.request(.getQuotes)
      .map(BashResponse.self, atKeyPath: nil, using: decoder)
      .map { bashResponse in
        bashResponse.quotes.map { ServiceQuoteCellViewModel(quote: $0) }
      }
      .asObservable()
      .do(onError: { error in
        print(error)
        self.isDownloading.value = false
      },
          onCompleted: {
            self.isDownloading.value = false
      })
      .retry(3)
      .catchErrorJustComplete()
      .bind(to: items)
      .disposed(by: disposeBag)
  }
}
