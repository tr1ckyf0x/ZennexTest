//
//  BashService.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 07/02/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import Moya

enum BashService {
  case getQuotes
}

extension BashService: TargetType {
  var baseURL: URL { return URL(string: "http://quotes.zennex.ru/api/v3/bash")! }
  
  var path: String {
    switch self {
    case .getQuotes: return "/quotes"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .getQuotes: return .get
    }
  }
  
  var task: Task {
    switch self {
    case .getQuotes: return .requestParameters(parameters: ["sort":"time"], encoding: URLEncoding.queryString)
    }
  }
  
  var sampleData: Data {
    switch self {
    case .getQuotes: return "Half measures are as bad as nothing at all.".data(using: .utf8)!
    }
  }
  
  var headers: [String: String]? {
    return ["Content-type": "application/json"]
  }
}
