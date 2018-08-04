//
//  SearchCollectionViewController.swift
//  vk6042041
//
//  Created by james404 on 11/08/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import UIKit
import VK_ios_sdk

private let reuseIdentifier = ConstantsStruct.CellIdentifiers.FoundUsersCollectionViewCell
// про использование NSCache нашел тут https://stackoverflow.com/questions/37018916/swift-async-load-image
private let kLazyLoadCellImageViewTag = 1

class SearchCollectionViewController: UICollectionViewController, ControllerNeedToHaveThisMethod, UIGestureRecognizerDelegate  {
  
  // MARK: Model
  
  // part of our Model
  // Array of Users
  // and corresponds to our collection view
  var foundUsers:[User]? = []
  
//  let contentOffset_KeyPath = "frame"
  
  
  
  var itsAFirstCell = true
   var lastSearchTime = DispatchTime.now()
  var itIsAFirstApearanceOfTheView = true
  var oldScrollViewContentOffsetY: CGFloat = 0.0
   var needCalculateItemSize = true
  var itemWidth: CGFloat = 0.0
  var showStatusBar = false {
    didSet{
      setNeedsStatusBarAppearanceUpdate()
//      collectionView?.collectionViewLayout.invalidateLayout()
//      print("showStatusBar = \(showStatusBar),  prefersStatusBarHidden = \(prefersStatusBarHidden)")
    }
  }
//  let statusBarHeight = UIApplication.shared.statusBarFrame.height

  
  
  //добавил протокол и свойство comeBackFromUserDetail  ,   так как при возврате от USER Detail система автоматически ставит navigationBar ( даже если он не виден - все равно isHidden == false ) и в результате на  phone X все съезжает collectionView frame из-за того что обнуляется свойство collectionView?.frame.origin.y == 0.0 когда в портрете
  var comeBackFromUserDetail = false
  
  // public part of our Model
  // when this is set
  // we'll reset our findedUsers Array
  // to reflect the result of fetching Users that match
  var searchParameters: [String: Any]? {
    didSet{
      /*if isViewLoaded && (view.window != nil) { // 
       (view.window != nil) этот вариант не подойдет
       т.к. searchParameters может изменяться из контролера в котором фильтр поиска изменяется
       */
         searchForUsers(true)
     }
  }
  
  
  func setComeBackFromUserDetailToTrue() {
    comeBackFromUserDetail = true
  }
  
  // MARK: Updating the Collection view
  func searchForUsers(_ newSearch: Bool = false) {
    
    guard isViewLoaded && (view.window != nil) else {
      /*if isViewLoaded && (view.window != nil) { //
       (view.window != nil) этот вариант не подойдет
       т.к. searchParameters может изменяться из контролера в котором фильтр поиска изменяется
       */
      return
    }
    
    guard var searchParameters = searchParameters else {
      presentAlert(withTitle: "Предупреждение", withMessage: "не заданы парамеры поиска")
      return
    }
    
    sleepIfNeeded(sleepFromTime: lastSearchTime, sleepTime_ms: 500)
    
    lastSearchTime = DispatchTime.now()
    
    if newSearch {
      foundUsers?.removeAll()
      collectionView?.reloadData()
    }
 
    searchParameters[VK_API_OFFSET] = foundUsers?.count ?? 0
    

    print("Парамеры поиска \(searchParameters)" )
    
    var request = VKApi.users().search(searchParameters)
    if request == nil {
      presentAlert(withTitle: "Предупреждение", withMessage: "не заданы парамеры поиска")
    }
    
    print( "Начанаем новый поиск : \(currentTimeString())")
    
    self.view.addActivityIndicator()
    
    request?.debugTiming = true
    request?.requestTimeout = 10
    request?.execute(resultBlock: { [weak self] (response: VKResponse?) in
      
       self?.view.removeActivitiIndicator()
      
      guard let jsonString = response?.responseString ,
        let data = jsonString.data(using: .utf8)
        else  {
          return
      }
      var newItems = [User]()
      do {
        let info = try  JSONDecoder().decode(UsersInfo.self, from: data)
        
        newItems = info.response.items
        
 
        self?.foundUsers = (self?.foundUsers ?? [User]()) + newItems
        print( "Количество пользователей = \(self?.foundUsers?.count ?? 0)")
        self?.collectionView?.reloadData()
        
      } catch DecodingError.dataCorrupted(let context) {
        print(context)
      } catch DecodingError.keyNotFound(let key, let context) {
        print("Key '\(key)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
      } catch DecodingError.valueNotFound(let value, let context) {
        print("Value '\(value)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
      } catch DecodingError.typeMismatch(let type, let context)  {
        print("Type '\(type)' mismatch:", context.debugDescription)
        print("codingPath:", context.codingPath)
      } catch {
        print("error: ", error)
      }
      
      if self?.foundUsers?.count == 0 {
        let error_message = "не найдено ни одного пользователя по параметрам \(searchParameters)"
        print(error_message)
        self?.presentAlert(withTitle: "Предупреждение", withMessage: "\(error_message) ")
      }
      
      request = nil
      } , errorBlock: { (error : Error?) in
        print("error = \(String(describing: error))")
      request = nil
    })

   }
  
  // Added after lecture for REFRESHING
  @IBAction func refresh(_ sender: UIRefreshControl) {
    searchForUsers()
  }
  
  
//  @objc private func swipeUpOrDown(swipe: UISwipeGestureRecognizer) {
//
//    collectionView?.isScrollEnabled = true
//  }
  
//  lazy var panGesture =  UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture: )))
  
//  @objc private func handlePanGesture(gesture: UIPanGestureRecognizer  ) {
//
//    if gesture.state == .ended {
//      collectionView?.isScrollEnabled = true
//    }
//
//  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    //collectionView?.contentInsetAdjustmentBehavior =  .never
    
    calculateItemSize()
    
//    addCollectionViewObserver()
    
    self.navigationController?.hidesBarsOnSwipe = true
    
//    panGesture.delegate = self
//    collectionView?.addGestureRecognizer(panGesture)
    
//    let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpOrDown(swipe:)))
//    upSwipe.direction = .up
//    self.collectionView?.addGestureRecognizer(upSwipe )
//
//    let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpOrDown(swipe:)))
//    downSwipe.direction = .down
//    self.collectionView?.addGestureRecognizer(downSwipe )
    
//    for gesture in (self.collectionView?.gestureRecognizers)!
//    {
//      // get the good one, i discover there are 2
////      if(gesture is UISwipeGestureRecognizer)
////      {
////        // replace delegate by yours (Do not forget to implement the gesture protocol)
////        (gesture as! UISwipeGestureRecognizer).delegate = self
////        print(" gesture = \(gesture)")
////      }
//
//
////      if  (gesture.classForCoder.description() ==  "UIScrollViewPanGestureRecognizer")
////      {
////        (gesture ).require(toFail: pinchGesture)
//////        gesture.isEnabled = false
////        print(" gesture! = \(gesture)")
////
////        //      myUIScrollViewPagingSwipeGestureRecognizer = otherGestureRecognizer
////        //      return true
////      }
//////
////
////          if  (gesture.classForCoder.description() ==  "UIScrollViewPagingSwipeGestureRecognizer")
////          {
////            gesture.require(toFail: pinchGesture)
//////            gesture.isEnabled = false
////            print(" gesture! = \(gesture)")
////
////      //      myUIScrollViewPagingSwipeGestureRecognizer = otherGestureRecognizer
////            //      return true
////          }
//
//    }

    
//    self.navigationController?.navigationBar.alpha = 0.15
    //navigationController?.view.backgroundColor = UIColor.clear

  }
 
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if itIsAFirstApearanceOfTheView {
      itIsAFirstApearanceOfTheView = false
      searchForUsers()
    }
    // добавил calculateNewCollectionFrameOrigin_and_CollectionFrame для того:
    // чтобы после того как обратно возращался из UserInfoCollectionViewController - восстановиить положение клеток
    // иначе съезжает наверх
    //  Добавил анимацию, чтобы плавно делал calculateNewCollectionFrameOrigin_and_CollectionFrame
    //UIView.animate(withDuration: 0.5, animations: {self.calculateNewCollectionFrameOrigin_and_CollectionFrame()})
 
  }
  
 
    // MARK: - Navigation
  
   // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if segue.identifier == ConstantsStruct.SegueIdentifiers.SHOW_USER_INFO, let row = sender as? Int {
      if let userVC = segue.destination as? UserInfoCollectionViewController {
        userVC.user = foundUsers![row]

      }
     }
   }
 
  // MARK: UICollectionViewDataSource
  
  
  // MARK: UICollectionViewDelegate
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    performSegue(withIdentifier: ConstantsStruct.SegueIdentifiers.SHOW_USER_INFO, sender: indexPath.row)
  }
  // MARK: Sizing
  override var prefersStatusBarHidden: Bool {
//    if let navCon = navigationController {
//      return navCon.navigationBar.isHidden
//    }
    if showStatusBar {
      return false
    }
 
    return true
  }
  
  var numberOfPhotosColumns = ConstantsStruct.SearchesDefaults.numberOfPhotosColumns {
    didSet{
      ConstantsStruct.SearchesDefaults.numberOfPhotosColumns = numberOfPhotosColumns
      needCalculateItemSize = true
//      UIView.animate(withDuration: 1.95) {
        self.calculateItemSize()

//      }
      //collectionView?.collectionViewLayout.invalidateLayout()
    }
  }
  
  var  maxZoomingScale: CGFloat = 0.0
  var  minZoomingScale: CGFloat = 0.0
  
  @IBOutlet var pinchGesture: UIPinchGestureRecognizer! {
    didSet{
      pinchGesture.delegate = self
    }
  }
  
//  func addCollectionViewObserver() {
//    //https://www.youtube.com/watch?v=OlpCyPcLSp4
//    collectionView?.addObserver(self, forKeyPath: contentOffset_KeyPath, options: [.old, .new], context: nil)
//  }
  
//  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
////    if let keypath == keyPath,  keypath == contentOffset_KeyPath, let collectionView == object as? UICollectionView {
//    if let keypath = keyPath, keypath == contentOffset_KeyPath, let collectionView = object as? UICollectionView {
//
//      // dbltj https://www.youtube.com/watch?v=OlpCyPcLSp4  14:11
//      if collectionView.isScrollEnabled == false {
//        collectionView.contentOffset.y = fixedCollectionViewOffsetY
//      }
//    }
//
//
//  }
 
//  deinit {
//    collectionView?.removeObserver(self, forKeyPath: contentOffset_KeyPath)
//  }
  
  var zoomingNumber: CGFloat = 0.0
//  var fixedCollectionViewOffsetY: CGFloat = 0.0
  @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
    
 
 //    if  sender.state == .began ||  sender.state == .possible || sender.state == .recognized {
      if  sender.state ==   .began  {
        
        //  делаем скролл в самое начало  так ка только в этом случае нормально - плавно идет анимация увеличения размера клетки или уменьшения
        self.showStatusBar = false
//        UIView.animate(withDuration: 1.0) {
          self.navigationController?.setNavigationBarHidden(true, animated: false)

          self.collectionView?.contentOffset.y = 0.0 //- UIApplication.shared.statusBarFrame.height

//        }

        
//      collectionView?.isScrollEnabled = false
//        collectionView?.isUserInteractionEnabled = false
//  //      collectionView?.delaysContentTouches
//      //  collectionView?.canCancelContentTouches = false
////      self.fixedCollectionViewOffsetY = self.collectionView!.contentOffset.y
//      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 * ConstantsStruct.Durations.pinchCellResizeInSeconds) {
//        self.collectionView?.isScrollEnabled = true
//        self.collectionView?.isUserInteractionEnabled = true
//       }
        
    }

    if sender.state == .began {
      maxZoomingScale = 1.0
      minZoomingScale = 1.0
    }
    else  if sender.state == .changed {
      maxZoomingScale = max(maxZoomingScale, sender.scale, 1)
      minZoomingScale = min(minZoomingScale, sender.scale, 1)
    } else if sender.state == .ended {
      
      let difMax = abs(maxZoomingScale - 1)
      let difMin = abs(minZoomingScale - 1)
      
      numberOfPhotosColumns = min(10,max( numberOfPhotosColumns + ( difMin > difMax ? 1 : -1) , 1))
      
      print(" difMax = \(difMax), difMin = \(difMin)")
    }
 
//   //   РАБОТАЕТ
//    let dif = (1.0 - sender.scale) * 7
//    zoomingNumber += dif
//    zoomingNumber = max(1, min(100,zoomingNumber))
//    numberOfPhotosColumns = min(10,max( Int(floor(zoomingNumber / 10)), 1))
//
//
//     print(" sender = \(sender.scale),  numberOfPhotosColumns = \(numberOfPhotosColumns), maxZoomingScale = \(maxZoomingScale), minZoomingScale = \(minZoomingScale)")
    
    
    
    
    
     sender.scale = 1
    }
  
  private func calculateItemSize() {
    
    if needCalculateItemSize == false {
      return
    }
    needCalculateItemSize = false
    
    itemWidth = windowTraitParameters.minSize / CGFloat( numberOfPhotosColumns)
    
    let layout  = collectionViewLayout as! UICollectionViewFlowLayout
    UIView.animate(withDuration: ConstantsStruct.Durations.pinchCellResizeInSeconds) {
      layout.itemSize = CGSize(width: self.itemWidth, height: self.itemWidth)
    }
    
    
  }
  
  var windowTraitParameters: ( maxSize: CGFloat, minSize: CGFloat, inPortrait: Bool,topPadding:CGFloat, rightPadding:CGFloat, maxAllowableCollectionViewHeight: CGFloat, maxAllowableCollectionViewWidth: CGFloat)
  {
    let maxSize: CGFloat
    let minSize: CGFloat
    let inPortrait: Bool
    var maxAllowableCollectionViewHeight: CGFloat
    let maxAllowableCollectionViewWidth: CGFloat
    
    let window = UIApplication.shared.keyWindow
    let topPadding = window!.safeAreaInsets.top
    //    let bottomPadding = window!.safeAreaInsets.bottom
    let rightPadding = window!.safeAreaInsets.right
    
    if window!.frame.height > window!.frame.width {
      maxSize = window!.frame.height
      minSize = window!.frame.width
      inPortrait = true
    } else {
      inPortrait = false
      maxSize = window!.frame.width
      minSize = window!.frame.height
    }
    
    
    if inPortrait {
      maxAllowableCollectionViewHeight = maxSize
      maxAllowableCollectionViewHeight = maxAllowableCollectionViewHeight + itemWidth / 5

      maxAllowableCollectionViewWidth = minSize
    } else {
      maxAllowableCollectionViewHeight = minSize
      maxAllowableCollectionViewWidth = maxSize
    }
    
    
    if let navBar = navigationController?.navigationBar {
      if !navBar.isHidden {
        maxAllowableCollectionViewHeight = maxAllowableCollectionViewHeight - navBar.frame.height
      }
    }
    if showStatusBar {
      maxAllowableCollectionViewHeight  = maxAllowableCollectionViewHeight - UIApplication.shared.statusBarFrame.height
    }
    
    return (maxSize, minSize, inPortrait,topPadding, rightPadding ,maxAllowableCollectionViewHeight, maxAllowableCollectionViewWidth )
  }
  
  func calculateNewCollectionFrameOrigin_and_CollectionFrame( ) {
    
    let numberOfrows = floor( (windowTraitParameters.maxAllowableCollectionViewHeight) / itemWidth )
    let numberOfColumns = floor( (windowTraitParameters.maxAllowableCollectionViewWidth) / itemWidth )
    UIView.animate(withDuration: 0.5) {
      
      self.collectionView?.frame.size.height = numberOfrows * self.itemWidth
      self.collectionView?.frame.size.width = numberOfColumns * self.itemWidth
      
      var heightOfFreeSpaceOnTop: CGFloat = 0.0
      if self.windowTraitParameters.topPadding == 0 {
        heightOfFreeSpaceOnTop = (self.windowTraitParameters.maxAllowableCollectionViewHeight -  self.collectionView!.frame.size.height) / 2
      }
      
      var widthOfFreeSpaceOnSide: CGFloat = 0.0
      if self.windowTraitParameters.rightPadding == 0 {
        widthOfFreeSpaceOnSide = (self.windowTraitParameters.maxAllowableCollectionViewWidth -  self.collectionView!.frame.size.width) / 2
      }
      
      if self.windowTraitParameters.inPortrait {
        
        if let navCon =  self.navigationController, let colView = self.collectionView {
          if navCon.navigationBar.isHidden || self.comeBackFromUserDetail {
            self.collectionView?.frame.origin.y =  self.windowTraitParameters.topPadding + heightOfFreeSpaceOnTop
          } else {
            if self.numberOfPhotosColumns  > 1  {
              self.collectionView?.frame.origin.y =  0.0
            } else {
              let freeSpace = self.windowTraitParameters.maxAllowableCollectionViewHeight - navCon.navigationBar.frame.height - colView.frame.height
              if freeSpace > 0.0 {
                self.collectionView?.frame.origin.y =  self.windowTraitParameters.topPadding + heightOfFreeSpaceOnTop - navCon.navigationBar.frame.height
              }
              
            }
          }
          self.collectionView?.frame.origin.x = 0.0
        }
      } else {
        self.collectionView?.frame.origin.y = 0.0
        self.collectionView?.frame.origin.x = self.windowTraitParameters.rightPadding + widthOfFreeSpaceOnSide
      }
      
    }
    
    
    //    print(" <calculateNewCollectionFrameOrigin_and_CollectionFrame==================>>>>>>)")
    //    print("collectionView?.frame.origin.y = \(collectionView?.frame.origin.y ?? 0), view.safeAreaInsets.top = \(view.safeAreaInsets.top) maxAllowableCollectionViewHeight = \(windowTraitParameters.maxAllowableCollectionViewHeight), collectionView?.frame.height = \(collectionView!.frame.height)")
  }
  
  // MARK:  Scroll view
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    var navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.size.height
//    var navBarVisibilityHasChanged = false
    if oldScrollViewContentOffsetY != scrollView.contentOffset.y {
      
      if oldScrollViewContentOffsetY  >  scrollView.contentOffset.y  + windowTraitParameters.maxAllowableCollectionViewHeight / 2 {
        print("scroll DOWN")
        comeBackFromUserDetail = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        showStatusBar = true
        navBarHeight = 0.0
//        navBarVisibilityHasChanged = true
        
      }  else if oldScrollViewContentOffsetY  + windowTraitParameters.maxAllowableCollectionViewHeight / 2 < scrollView.contentOffset.y {
        print("scroll UP")
        comeBackFromUserDetail = false

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        showStatusBar = false

//        navBarVisibilityHasChanged = true

      }
    }
    
//    if  navBarVisibilityHasChanged == true {
//      calculateNewCollectionFrameOrigin_and_CollectionFrame()
//      collectionView?.collectionViewLayout.invalidateLayout()
//
//    }

    
    oldScrollViewContentOffsetY = scrollView.contentOffset.y + navBarHeight
    
//    print(" <<scrollViewDidEndDecelerating ===================>>")
//    print("  collectionView?.frame.height = \(String(describing: collectionView?.frame.height))" )
//    print(" collectionView.contentOffset.y = \( collectionView?.contentOffset.y ?? 0))")
//    print(" collectionView.frame.origin.y = \( collectionView?.frame.origin.y ?? 0)")
//    print(" oldScrollViewContentOffsetY = \( oldScrollViewContentOffsetY  ) beginCollectionViewHeght = \(windowTraitParameters.maxAllowableCollectionViewHeight)")
//    print(" view.safeAreaInsets.top = \( view.safeAreaInsets.top  ) bottom = \(view.safeAreaInsets.bottom) left = \(view.safeAreaInsets.left) right = \(view.safeAreaInsets.right) ")
  }

  //MARK:  UIGestureRecognizerDelegate
  
//  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//    //    if gestureRecognizer == .
////    print(" gestureRecognizer = \(gestureRecognizer)")
////    print(" otherGestureRecognizer = \(otherGestureRecognizer)")
//
//
////    if otherGestureRecognizer == self.pinchGesture {
////      print("!!!")
////    }
//
//
////    if (gestureRecognizer.classForCoder.description() ==  "UIScrollViewPagingSwipeGestureRecognizer")  {
////      print("!!!")
////    }
//
//    if  gestureRecognizer  ==  self.panGesture  && otherGestureRecognizer == self.pinchGesture {
//      return true
//    }
//        print(" gestureRecognizer = \(gestureRecognizer)")
//        print(" otherGestureRecognizer = \(otherGestureRecognizer)")
//
//    //let x = pinchGesture.classForCoder
//    return false
//  }

}


// MARK UICollectionViewDataSource
extension SearchCollectionViewController {
  
  override  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return foundUsers?.count ?? 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FoundUserCollectionViewCell
    
    // Configure the cell
    cell.rowNumber = indexPath.row + 1
    cell.user = foundUsers?[indexPath.row]
    updateImageForCell(cell, inCollectionView: collectionView, atIndexPath: indexPath)
    
    return cell
  }
  
  func updateImageForCell(_ cell: FoundUserCollectionViewCell, inCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) {
    let imageView = cell.viewWithTag(kLazyLoadCellImageViewTag) as! UIImageView
    imageView.image = kLazyLoadPlaceholderImage
    // load image.
    
    if let imageURL = cell.user?.photo_200 {
      ImageManager.sharedInstance.downloadImageFromURL(imageURL, emptyCache: itsAFirstCell) { (success, image,imageURL ) -> Void in
        if success && image != nil && cell.user!.photo_200 == imageURL {
          imageView.image = image
        }
      }
    }
    itsAFirstCell = false
  }
 
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    if oldScrollViewContentOffsetY == 0.0 {
      oldScrollViewContentOffsetY = (collectionView?.contentOffset.y)!
    }
    calculateNewCollectionFrameOrigin_and_CollectionFrame()
  }
  
  
  
// MARK: - Lazy Loading of cells
 
//  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//    /*  раньше планировал делать следующий запрос когда досигли дна
//    // взято тут https://stackoverflow.com/questions/7706152/iphone-knowing-if-a-uiscrollview-reached-the-top-or-bottom
//    let scrollViewHeight = scrollView.frame.size.height
//    let scrollContentSizeHeight = scrollView.contentSize.height
//    let scrollOffset = scrollView.contentOffset.y
//
//    //    print("scrollOffset + scrollViewHeight = \(scrollOffset + scrollViewHeight), scrollContentSizeHeight = \(scrollContentSizeHeight)")
//
//    if (scrollOffset == 0)
//    {
//      // then we are at the top
//    }
//    else if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight )
//    {
//      // then we are at the end
//      print("достигнули дна ")
//      //searchForUsers()
//
//    }
//     //    print("////////////////////////////////////////")
//    //    print("scrollContentSizeHeight = \(scrollContentSizeHeight)")
//    //    print("scrollOffset + scrollViewHeight = \(scrollOffset + scrollViewHeight)")
//    */
//   }
  
}




