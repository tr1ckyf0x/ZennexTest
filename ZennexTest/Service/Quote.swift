//
//  Quote.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 26/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation

class BashQuotes: Codable {
  let total: UInt
  let last: Date
  let quotes: [Quote]
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    total = try values.decode(UInt.self, forKey: .total)
    let lastString = try values.decode(String.self, forKey: .last)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let lastDate = dateFormatter.date(from: lastString) else {
      throw DecodingError.dataCorruptedError(forKey: .last, in: values, debugDescription: "Can not decode Date")
    }
    last = lastDate
    quotes = try values.decode([Quote].self, forKey: .quotes)
  }
}

class Quote: Codable {
  let id: UInt
  let description: String
  let time: Date
  let rating: Int
  
  enum CodingKeys: String, CodingKey {
    case id
    case description
    case time
    case rating
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(UInt.self, forKey: .id)
    description = try values.decode(String.self, forKey: .description)
      .replacingOccurrences(of: "<br>", with: "\n")
      .replacingOccurrences(of: "&lt;", with: "<")
      .replacingOccurrences(of: "&gt;", with: ">")
      .replacingOccurrences(of: "&quot;", with: "\"")
      .replacingOccurrences(of: "&apos;", with: "'")
      .replacingOccurrences(of: "&amp;", with: "&")
    let timeString = try values.decode(String.self, forKey: .time)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let timeDate = dateFormatter.date(from: timeString) else {
      throw DecodingError.dataCorruptedError(forKey: .time, in: values, debugDescription: "Can not decode Date")
    }
    time = timeDate
    rating = try values.decode(Int.self, forKey: .rating)
  }
}
