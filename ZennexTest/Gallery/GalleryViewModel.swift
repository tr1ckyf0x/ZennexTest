//
//  GalleryViewModel.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 26/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class GalleryViewModel {
  
  var imageUrls = Variable<[URL]>([])
  
  init() {
    Alamofire
      .request("https://tr1ckyf0x.com/witcher/witcher.json")
      .responseData { response in
        guard let data = response.result.value
          else { print("Can not load data"); return }
        do {
          let decoder = JSONDecoder()
          self.imageUrls.value = try decoder
            .decode([URL].self, from: data)
        } catch { print("Can not decode data") }
    }
  }
  
}
