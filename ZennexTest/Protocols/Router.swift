//
//  Router.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 28/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import Foundation
import UIKit

protocol Router {
  func route(to routeID: String, from context: UIViewController, parameters: Any?)
}
