//
//  SearchViewController.swift
//  vk6042041
//
//  Created by james404 on 04/08/2018.
//  Copyright © 2018 Vladimir Filippov. All rights reserved.
//

import UIKit
import VK_ios_sdk

private let reuseIdentifier = ConstantsStruct.CellIdentifiers.FoundUsersCollectionViewCell

class SearchViewController: UIViewController, UICollectionViewDelegate, UIScrollViewDelegate {
  
  // MARK: DataSource
  var foundUsers:[User]? = []  {
    didSet {
      foundUsersCollectionView?.reloadData()
    }
  }
  var lastSearchTime = DispatchTime.now()
  var itIsAFirstApearanceOfTheView = true
  var needCalculateItemSize = true
  var itemWidth: CGFloat = 0.0
  var showStatusBar = false {
    didSet{
      setNeedsStatusBarAppearanceUpdate()
    }
  }
  
  
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  //MARK: ViewController
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    foundUsersCollectionView.decelerationRate = foundUsersCollectionView.decelerationRate / 5
    
    
    foundUsersCollectionView.isPagingEnabled = false
    
    calculateItemSize()
    
    self.navigationController?.hidesBarsOnSwipe = true
    
    
    title = "Users"
    
    //    searchBarBoundsY = (navigationController?.navigationBar.frame.height ?? 0.0) + UIApplication.shared.statusBarFrame.height
    addCollectionViewObserver()
    
    searchForUsers()
    
    constraints()
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if itIsAFirstApearanceOfTheView {
      itIsAFirstApearanceOfTheView = false
      searchForUsers()
    }
  }
  
  // MARK: Sizing
  override var prefersStatusBarHidden: Bool {
    if showStatusBar {
      return false
    }
    return true
  }
  
  var numberOfPhotosColumns = ConstantsStruct.SearchesDefaults.numberOfPhotosColumns {
    didSet{
      ConstantsStruct.SearchesDefaults.numberOfPhotosColumns = numberOfPhotosColumns
      needCalculateItemSize = true
      self.calculateItemSize()
    }
  }
  
  var  maxZoomingScale: CGFloat = 0.0
  var  minZoomingScale: CGFloat = 0.0
  
  //добавил протокол и свойство comeBackFromUserDetail  ,   так как при возврате от USER Detail система автоматически ставит navigationBar ( даже если он не виден - все равно isHidden == false ) и в результате на  phone X все съезжает collectionView frame из-за того что обнуляется свойство collectionView?.frame.origin.y == 0.0 когда в портрете
  var comeBackFromUserDetail = false
  
  func setComeBackFromUserDetailToTrue() {
    comeBackFromUserDetail = true
  }
  
  private func calculateItemSize() {
    
    if needCalculateItemSize == false {
      return
    }
    needCalculateItemSize = false
    
    itemWidth = cvp_safeAreaFrameMinSize / CGFloat( numberOfPhotosColumns)
  }
  
  
  var cvp_inPortrait: Bool {
    return cvp_safeAreaFrame.height > cvp_safeAreaFrame.width
  }
  
  var cvp_safeAreaFrameMinSize: CGFloat {
    return cvp_safeAreaFrame.height > cvp_safeAreaFrame.width ? cvp_safeAreaFrame.width : cvp_safeAreaFrame.height
  }
  
  var cvp_safeAreaFrameMaxSize: CGFloat {
    return cvp_safeAreaFrame.height > cvp_safeAreaFrame.width ? cvp_safeAreaFrame.height : cvp_safeAreaFrame.width
  }
  
  var cvp_safeAreaFrame: CGRect {
    return   safeArea().layoutFrame
  }
  
  var cvp_numberOfColumnsForCurrentDeviceOrientation: Int {
    return Int( floor(foundUsersCollectionView.frame.width / itemWidth))
  }
  
  var cvp_numberOfRowsForCurrentDeviceOrientation: Int {
    return Int(floor( (cvp_maxAllowableCollectionViewHeight + itemWidth / 5) /  itemWidth ))
  }
  
  var cvp_currentPageNumber: Int {
    let pageHeight = foundUsersCollectionView.frame.size.height
    return Int(ceil( foundUsersCollectionView.contentOffset.y / pageHeight)) + 1
  }
  
  var cvp_searchBarFrameHeightIfItVisible: CGFloat {
    if let navigationBar = self.navigationController?.navigationBar {
      return cvp_currentPageNumber == 1 ? (navigationBar.isHidden ? 0.0 : searchBar.frame.height)  : 0.0
    } else {
      return 0.0
    }
  }
  
  var cvp_navBarAndStatusHeightIfTheyVisible_else_safeAreaHeight: CGFloat {
    if let navigationBar = self.navigationController?.navigationBar {
      return navigationBar.isHidden ?  safeArea().layoutFrame.origin.y : navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
    } else {
      return 0.0
    }
  }
  
  var cvp_maxAllowableCollectionViewHeight: CGFloat {
    return   foundUsersCollectionView.superview!.frame.height - cvp_searchBarFrameHeightIfItVisible - cvp_navBarAndStatusHeightIfTheyVisible_else_safeAreaHeight
  }
  
  var cvp_collectionHeightConstraint: CGFloat {
    return  CGFloat( cvp_numberOfRowsForCurrentDeviceOrientation )  *  itemWidth
  }
  
  var cvp_collectionWidthConstraint: CGFloat {
    return CGFloat(  cvp_numberOfColumnsForCurrentDeviceOrientation )  *  itemWidth
  }
  
  
  var wasFirstCalculationOf_FirstVisibleCellNumber = false
  
  private func calculateFirstAndLastVisibleCellNumbers()
  {
    if let  firstVisibleCellIndexPath = foundUsersCollectionView.indexPathForItem(at: CGPoint(x: foundUsersCollectionView.contentOffset.x  + itemWidth /  2.0 , y: foundUsersCollectionView.contentOffset.y +  itemWidth /  2.0 ))    {
      firstVisibleCellNumber = firstVisibleCellIndexPath.item
    }
    
    if let  lastVisibleCellIndexPath = foundUsersCollectionView.indexPathForItem(at: CGPoint(x: foundUsersCollectionView.contentOffset.x + foundUsersCollectionView.frame.width - itemWidth /  2.0 , y: foundUsersCollectionView.contentOffset.y + cvp_collectionHeightConstraint -  itemWidth /  2.0 ))    {
      
      lastVisibleCellNumber = lastVisibleCellIndexPath.item
    }
  }
  
  var firstVisibleCellNumber = 0
  {
    didSet{
      
      wasFirstCalculationOf_FirstVisibleCellNumber = true
      
      print("firstVisibleCellIndexPath FROM calculateNewCollectionFrameOrigin_and_CollectionFrame = \(firstVisibleCellNumber + 1)")
      //      previousFirstVisibleCellNumber = oldValue
    }
  }
  
  var lastVisibleCellNumber = 0
  {
    didSet {
      print("lastVisibleCellIndexPath FROM calculateNewCollectionFrameOrigin_and_CollectionFrame = \(lastVisibleCellNumber + 1)")
      //      previousLastVisibleCellNumber = oldValue
    }
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
  
  @IBOutlet weak var foundUsersCollectionView: UICollectionView!
  
  var searchParameters: [String: Any]?
  
  //MARK: ScrollView delegate
  
  //MARK: Observation
  
  @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
  
  var searchBarBoundsY: CGFloat = 0.0
  
  @IBOutlet weak var collectionLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionWidthConstraint: NSLayoutConstraint!
  
  let nameOf_contentOffset_keyPath = "contentOffset"
  //  let nameOf_contentInset_keyPath =  "contentInset"
  let nameOf_bounds_keyPath = "bounds"
  var oldBoundsWidth: CGFloat = 0.0
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    //    if traitCollection.verticalSizeClass == .compact {
    //      searchBar.isHidden = true
    //    } else {
    //      searchBar.isHidden = false
    //    }
    constraints()
  }
  
  private func constraints() {
    let margins = safeArea()
    foundUsersCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
    switch UIDevice.current.orientation {
    case .portrait:
      print("Portrait")
      collectionLeadingConstraint?.constant = 0.0
      collectionTrailingConstraint?.constant = 0.0
      collectionTopConstraint?.constant = 0.0
      
    case .landscapeLeft:
      //      collectionLeadingConstraint?.isActive = true
      collectionLeadingConstraint?.constant = margins.layoutFrame.origin.x   + (foundUsersCollectionView.frame.width - cvp_collectionWidthConstraint )
      
      //      collectionTrailingConstraint?.isActive = true
      collectionTrailingConstraint?.constant = 0.0
      
      //      collectionView.superview?.layoutIfNeeded()
      print("Landscape Left")
    case .landscapeRight:
      //      collectionLeadingConstraint?.isActive =  true
      collectionLeadingConstraint?.constant =  0.0
      //      collectionTrailingConstraint?.isActive = true
      collectionTrailingConstraint?.constant = margins.layoutFrame.origin.x   +  (foundUsersCollectionView.frame.width - cvp_collectionWidthConstraint )
      print("Landscape Right")
      //      collectionView.superview?.layoutIfNeeded()
      
    case .portraitUpsideDown:
      print("Portrait Upside Down")
    default:
      print("Unable to Determine State")
    }
    collectionHeightConstraint?.constant = cvp_collectionHeightConstraint
  }
  
  private func safeArea() -> UILayoutGuide {
    //https://www.youtube.com/watch?v=TU7C4jW6ASc
    if #available(iOS 11, *) {
      let margins = foundUsersCollectionView.superview!.safeAreaLayoutGuide
      return margins
    } else {
      let margins = foundUsersCollectionView.superview!.layoutMarginsGuide
      return margins
    }
  }
  
  func addCollectionViewObserver() {
    //https://www.youtube.com/watch?v=OlpCyPcLSp4
    foundUsersCollectionView.addObserver(self, forKeyPath: nameOf_contentOffset_keyPath, options: [.new, .old], context: nil)
    foundUsersCollectionView.addObserver(self, forKeyPath: nameOf_bounds_keyPath, options: [.new, .old], context: nil)
  }
  
  deinit {
    foundUsersCollectionView.removeObserver(self, forKeyPath: nameOf_contentOffset_keyPath)
    foundUsersCollectionView.removeObserver(self, forKeyPath: nameOf_bounds_keyPath)
    //    collectionView.removeObserver(self, forKeyPath: nameOf_contentInset_keyPath)
  }
  
  var lastContentOffset_Y_BeforPageHasStopped:CGFloat = 0.0
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
    lastContentOffset_Y_BeforPageHasStopped = scrollView.contentOffset.y
    calculateFirstAndLastVisibleCellNumbers()
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let keyPath = keyPath, let collectionView = object as? UICollectionView {
      
      if keyPath == nameOf_contentOffset_keyPath {
        collectionTopConstraint.constant =  max( 0.0, searchBar.frame.height - collectionView.contentOffset.y * 2.0 )
        
        searchBarTopConstraint.constant =  -1 * collectionView.contentOffset.y - searchBar.frame.height
        
        if (collectionView.contentOffset.y == 0.0 && lastContentOffset_Y_BeforPageHasStopped != 0.0) || !wasFirstCalculationOf_FirstVisibleCellNumber {
          // чтобы когда вернуться тапом на статус баре на самую первую страницу рассчитался бы первый и поседний видимый клетка
          lastContentOffset_Y_BeforPageHasStopped = 0.0
          calculateFirstAndLastVisibleCellNumbers()
          //          currentPage = 1
          //calculateNewCollectionFrameOrigin_and_CollectionFrame()
        }
      } else if keyPath == nameOf_bounds_keyPath {
        if oldBoundsWidth != collectionView.bounds.size.width {
          print(" bounds changed")
          oldBoundsWidth = collectionView.bounds.size.width
        }
      }
    }
  }
  
  private var pageWillBeTurnedUp: Bool? {
    didSet{
      if let isUp = pageWillBeTurnedUp  {
        UIView.animate(withDuration: 0.5) {
          self.navigationController?.setNavigationBarHidden(isUp, animated: false)
          self.showStatusBar = !isUp
          self.collectionHeightConstraint.constant = self.cvp_collectionHeightConstraint
        }
      }
    }
  }
  
  //  private var newTargetY: CGFloat = 0.0
  
  
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
    let newTargetY = targetContentOffset.pointee.y
    if lastContentOffset_Y_BeforPageHasStopped != newTargetY {
      if lastContentOffset_Y_BeforPageHasStopped > newTargetY {
        print("pDown ⬇︎ ⬇︎ ⬇︎ ")
        pageWillBeTurnedUp = false
      } else {
        print("pUp ⬆︎ ⬆︎ ⬆︎ ")
        pageWillBeTurnedUp = true
      }
    } else {
      pageWillBeTurnedUp = nil
    }
    
    if let isUp = pageWillBeTurnedUp {
      if isUp {
        
        let numberOfShownRows = CGFloat( ceil(Double(( lastVisibleCellNumber + 1) / cvp_numberOfColumnsForCurrentDeviceOrientation)))
        
        targetContentOffset.pointee.y = numberOfShownRows *  itemWidth
      } else {
        
        let numberOfRowsInNextPage = floor( cvp_collectionHeightConstraint / itemWidth )
        let maxQuantityOfCellsInNextPage = Int(numberOfRowsInNextPage) * cvp_numberOfColumnsForCurrentDeviceOrientation
        
        if maxQuantityOfCellsInNextPage > firstVisibleCellNumber {
          targetContentOffset.pointee.y  = 0.0
        } else {
          
          let numberOfCellsAboveNextPage = firstVisibleCellNumber   - maxQuantityOfCellsInNextPage
          let numberOfRowsAboveNextPage = ceil(Double(numberOfCellsAboveNextPage  / cvp_numberOfColumnsForCurrentDeviceOrientation))
          targetContentOffset.pointee.y = CGFloat(numberOfRowsAboveNextPage) * itemWidth
          
        }
      }
    }
  }
}

// MARK UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return foundUsers?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FoundUserCollectionViewCell
    // Configure the cell
    cell.rowNumber = indexPath.row + 1
    cell.user = foundUsers?[indexPath.item]
    
    return cell
  }
}

//MARK: UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: itemWidth, height: itemWidth)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return  UIEdgeInsets(top: 0.0 , left: 0.0, bottom: 0.0, right: 0.0)
  }
  
  func printDataForScrollView( _ cv: UIScrollView) {
    print("  cv.contentOffset.y = \(Int(cv.contentOffset.y)), cv Height=\(Int(cv.frame.height)), cv fr origin.y=\(Int(cv.frame.origin.y)) ")
  }
}


