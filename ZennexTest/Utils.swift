//
//  Extensions.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 28/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

func checkBy(regexPattern: String, text: String?) -> Bool {
  guard let text = text else { return false }
  guard let regex = try? NSRegularExpression(pattern: regexPattern, options: .caseInsensitive) else { return false }
  let range = NSRange(text.startIndex..., in: text)
  let found = regex.firstMatch(in: text, options: [], range: range)
  return found != nil
}

infix operator <->

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
  let bindToUIDisposable = variable.asObservable()
    .bind(to: property)
  let bindToVariable = property
    .subscribe(onNext: { n in
      variable.value = n
    }, onCompleted:  {
      bindToUIDisposable.dispose()
    })
  return CompositeDisposable(bindToUIDisposable, bindToVariable)
}

class Utils {
  static let sharedInstance = Utils()
  private init() {
    hourDateFormatter.dateFormat = "HH:mm"
  }
  
  let hourDateFormatter = DateFormatter()
}
