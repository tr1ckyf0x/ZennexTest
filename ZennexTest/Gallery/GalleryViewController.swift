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
  @IBOutlet weak var pageLabel: UILabel!
  var viewModel: GalleryViewModel?
  var zoomDelegate = ZoomDelegate()
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
        let imageScrollView = UIScrollView()
        let xPosition = self.scrollView.frame.width * CGFloat(i)
        imageScrollView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
        imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width, height: imageScrollView.frame.height)
        imageScrollView.minimumZoomScale = 1
        imageScrollView.maximumZoomScale = 5
        imageScrollView.delegate = self.zoomDelegate
        imageScrollView.showsVerticalScrollIndicator = false
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.isPagingEnabled = false
        imageScrollView.bounces = false
        self.scrollView.addSubview(imageScrollView)
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
        imageView.backgroundColor = UIColor.black
        imageView.contentMode = .scaleAspectFit
        imageScrollView.addSubview(imageView)
        Alamofire.request(array[i])
          .responseData { response in
            guard let data = response.result.value
            else { print("Cannot load image"); return }
            imageView.image = UIImage(data: data)
        }
      }
    })
    .disposed(by: rx.disposeBag)

  }

  @IBAction func backButtonPressed(_ sender: Any) {
    guard lastPage > 0 else { return }
    scrollView.setContentOffset(CGPoint(x: CGFloat(lastPage - 1) * scrollView.frame.width, y: 0) , animated: true)
  }
  @IBAction func nextButtonPressed(_ sender: Any) {
    guard let viewModel = viewModel,
      lastPage < viewModel.imageUrls.value.count - 1
      else { return }
    scrollView.setContentOffset(CGPoint(x: CGFloat(lastPage + 1) * scrollView.frame.width, y: 0) , animated: true)
  }
  
}

extension GalleryViewController: Identifiable {
  static var identifier: String { return "GalleryViewController" }
}

extension GalleryViewController: UIScrollViewDelegate {
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    addImagesNear()
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    addImagesNear()
  }
  
  func addImagesNear() {
    let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    guard currentPage != lastPage else { return }
    guard let viewModel = viewModel else { return }
    
    defer {
      lastPage = currentPage
    }
    
    // Проверяем есть ли на текущей позиции картинка (если пролистнули быстро и загрузиться не успела)
    let havePictureOnCurrentPage = scrollView.subviews
      .contains { Int($0.frame.origin.x) == Int(CGFloat(currentPage) * scrollView.frame.width) }
    if !havePictureOnCurrentPage {
      let imageScrollView = UIScrollView()
      let xPosition = scrollView.frame.width * CGFloat(currentPage)
      imageScrollView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
      imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width, height: imageScrollView.frame.height)
      imageScrollView.minimumZoomScale = 1
      imageScrollView.maximumZoomScale = 5
      imageScrollView.delegate = self.zoomDelegate
      imageScrollView.showsVerticalScrollIndicator = false
      imageScrollView.showsHorizontalScrollIndicator = false
      imageScrollView.isPagingEnabled = false
      imageScrollView.bounces = false
      scrollView.addSubview(imageScrollView)
      let imageView = UIImageView()
      imageView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
      imageView.backgroundColor = UIColor.black
      imageView.contentMode = .scaleAspectFit
      imageScrollView.addSubview(imageView)
      Alamofire.request(viewModel.imageUrls.value[currentPage])
        .responseData { response in
          guard let data = response.result.value
            else { print("Cannot load image"); return }
          imageView.image = UIImage(data: data)
      }
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
      let imageScrollView = UIScrollView()
      let xPosition = scrollView.frame.width * CGFloat(currentPage + 1)
      imageScrollView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
      imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width, height: imageScrollView.frame.height)
      imageScrollView.minimumZoomScale = 1
      imageScrollView.maximumZoomScale = 5
      imageScrollView.delegate = self.zoomDelegate
      imageScrollView.showsVerticalScrollIndicator = false
      imageScrollView.showsHorizontalScrollIndicator = false
      imageScrollView.isPagingEnabled = false
      imageScrollView.bounces = false
      scrollView.addSubview(imageScrollView)
      let imageView = UIImageView()
      imageView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
      imageView.backgroundColor = UIColor.black
      imageView.contentMode = .scaleAspectFit
      imageScrollView.addSubview(imageView)
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
      let imageScrollView = UIScrollView()
      let xPosition = scrollView.frame.width * CGFloat(currentPage - 1)
      imageScrollView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
      imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width, height: imageScrollView.frame.height)
      imageScrollView.minimumZoomScale = 1
      imageScrollView.maximumZoomScale = 5
      imageScrollView.delegate = self.zoomDelegate
      imageScrollView.showsVerticalScrollIndicator = false
      imageScrollView.showsHorizontalScrollIndicator = false
      imageScrollView.isPagingEnabled = false
      imageScrollView.bounces = false
      scrollView.addSubview(imageScrollView)
      let imageView = UIImageView()
      imageView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
      imageView.backgroundColor = UIColor.black
      imageView.contentMode = .scaleAspectFit
      imageScrollView.addSubview(imageView)
      Alamofire.request(viewModel.imageUrls.value[currentPage - 1])
        .responseData { response in
          guard let data = response.result.value
            else { print("Cannot load image"); return }
          imageView.image = UIImage(data: data)
      }
    }
  }
  
}

class ZoomDelegate: NSObject, UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return scrollView.subviews.first
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    // Центрирование изображения по центру при уменьшении
    var top = CGFloat(0)
    var left = CGFloat(0)
    if scrollView.contentSize.width < scrollView.bounds.size.width {
      left = (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5
    }
    if scrollView.contentSize.height < scrollView.bounds.size.height {
      top = (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5
    }
    scrollView.contentInset = UIEdgeInsetsMake(top, left, top, left)
  }
  
}
