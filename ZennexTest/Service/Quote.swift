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
}

class Quote: Codable {
  let id: UInt
  let description: String
  let time: Date
  let rating: Int
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(UInt.self, forKey: .id)
    time = try values.decode(Date.self, forKey: .time)
    rating = try values.decode(Int.self, forKey: .rating)
    let htmlEncodedString = try values.decode(String.self, forKey: .description)
    if let htmlEncodedStringData = htmlEncodedString.data(using: .unicode) {
      let attributedString = try NSAttributedString(data: htmlEncodedStringData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
      description = attributedString.string
    } else {
      description = htmlEncodedString
    }
  }
}
