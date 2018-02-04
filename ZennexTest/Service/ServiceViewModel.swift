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


// Следует выделить API в класс с енумом ендпонитнов, и функциями, возвращающими объекты
// Времени не хватило
// Также добавить проверку доступности сети, повтор запроса при ошибке, вывод сообщения пользователю
class ServiceViewModel {
  var items = Variable([ServiceQuoteCellViewModel]())
  var isDownloading = Variable(true)
  
  init() {
    Alamofire
      .request("http://quotes.zennex.ru/api/v3/bash/quotes?sort=time")
      .responseData { response in
        self.isDownloading.value = false
        guard let data = response.result.value
          else { print("Can not load data"); return }
        do {
          let decoder = JSONDecoder()
          self.items.value = try decoder
            .decode(BashQuotes.self, from: data)
            .quotes
            .map { ServiceQuoteCellViewModel(quote: $0) }
        } catch { print("Can not decode data") }
    }
  }
}
