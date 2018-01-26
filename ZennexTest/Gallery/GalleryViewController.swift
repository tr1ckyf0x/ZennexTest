//
//  GalleryViewController.swift
//  ZennexTest
//
//  Created by Владислав Лисянский on 26/01/2018.
//  Copyright © 2018 Владислав Лисянский. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

class GalleryViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  var viewModel: GalleryViewModel?
  var lastPage = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel = GalleryViewModel()
    viewModel?.imageUrls.asObservable()
      .filter { $0.count > 0 }
      .subscribe(onNext: { array in
      self.scrollView.subviews.forEach {
        $0.removeFromSuperview()
      }
      self.scrollView.contentSize = CGSize(width: CGFloat(array.count) * self.scrollView.frame.width, height: self.scrollView.frame.height)
      self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
      
      for i in 0 ..< 2 {
        let imageView = UIImageView()
        imageView.tag = i
        let xPosition = self.scrollView.frame.width * CGFloat(i)
        imageView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
        imageView.backgroundColor = UIColor.black
        imageView.contentMode = .scaleAspectFit
        self.scrollView.addSubview(imageView)
        Alamofire.request(array[i])
          .responseData { response in
            guard let data = response.result.value
            else { print("Cannot load image"); return }
            imageView.image = UIImage(data: data)
        }
      }
    })
    
    

  }

  @IBAction func backButtonPressed(_ sender: Any) {
  }
  @IBAction func nextButtonPressed(_ sender: Any) {
  }
  
}

extension GalleryViewController: Identifiable {
  static var identifier: String { return "GalleryViewController" }
}

extension GalleryViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    guard currentPage != lastPage else { return }
    guard let viewModel = viewModel else { return }
    
    defer {
      lastPage = currentPage
    }
    
    if currentPage > lastPage {
      // Удаляем все справа
      scrollView.subviews
        .filter { $0.frame.origin.x > scrollView.frame.size.width * CGFloat(currentPage) }
        .forEach { $0.removeFromSuperview() }
      // Удалить все что левее current - 1
      scrollView.subviews
        .filter { $0.frame.origin.x < scrollView.frame.size.width * CGFloat(currentPage - 1) }
        .forEach { $0.removeFromSuperview() }
      // Проверка что мы не с краю
      guard currentPage < viewModel.imageUrls.value.count - 1 else { return }
      // Добавить одну справа
      let imageView = UIImageView()
      imageView.tag = currentPage + 1
      let xPosition = scrollView.frame.width * CGFloat(currentPage + 1)
      imageView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
      imageView.backgroundColor = UIColor.black
      imageView.contentMode = .scaleAspectFit
      scrollView.addSubview(imageView)
      Alamofire.request(viewModel.imageUrls.value[currentPage + 1])
        .responseData { response in
          guard let data = response.result.value
            else { print("Cannot load image"); return }
          imageView.image = UIImage(data: data)
      }
    } else {
      // Удалить все слева
      scrollView.subviews
      .filter { $0.frame.origin.x < scrollView.frame.size.width * CGFloat(currentPage) }
        .forEach { $0.removeFromSuperview() }
      // Удалить все что правее current + 1
      scrollView.subviews
        .filter { $0.frame.origin.x > scrollView.frame.size.width * CGFloat(currentPage + 1) }
        .forEach { $0.removeFromSuperview() }
      // Проверка что мы не с краю
      guard currentPage > 0 else { return }
      // Добавить одну слева
      let imageView = UIImageView()
      imageView.tag = currentPage - 1
      let xPosition = scrollView.frame.width * CGFloat(currentPage - 1)
      imageView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
      imageView.backgroundColor = UIColor.black
      imageView.contentMode = .scaleAspectFit
      scrollView.addSubview(imageView)
      Alamofire.request(viewModel.imageUrls.value[currentPage - 1])
        .responseData { response in
          guard let data = response.result.value
            else { print("Cannot load image"); return }
          imageView.image = UIImage(data: data)
      }
    }
  }
}
