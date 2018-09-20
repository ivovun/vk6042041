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
class SearchViewController: UIViewController, UICollectionViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
  
  // MARK: DataSource
  var foundUsers:[User]? = []  {
    didSet {
      foundUsersCollectionView?.reloadData()
    }
  }
  var lastSearchTime = DispatchTime.now()
  var itIsAFirstApearanceOfTheView = true
  var needCalculateItemSize = true
  var itemWidth: CGFloat = 0.0 {
    didSet{
      print("-------------------------------------------------------------   --------------------------------------------\n ------new item size: = \(itemWidth)")
    }
  }
  var showStatusBar = false {
    didSet{
      setNeedsStatusBarAppearanceUpdate()
    }
  }
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  //MARK: ViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    foundUsersCollectionView.decelerationRate = foundUsersCollectionView.decelerationRate / 10
    
    foundUsersCollectionView.isPagingEnabled = false
    
    calculateItemSize()
    
    self.navigationController?.hidesBarsOnSwipe = true
    
    title = "Users"
    
    //    searchBarBoundsY = (navigationController?.navigationBar.frame.height ?? 0.0) + UIApplication.shared.statusBarFrame.height
    addCollectionViewObserver()
    
    searchForUsers()
    
    constraints()
    
    collectionTopConstraint.constant =  ConstantsStruct.Sizes.searchBarHeight
    searchBarTopConstraint.constant = 0.0
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if itIsAFirstApearanceOfTheView {
      itIsAFirstApearanceOfTheView = false
      searchForUsers()
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    if showStatusBar {
      return false
    }
    return true
  }
  
  // MARK: Sizing
  
  var numberOfPhotosColumns = ConstantsStruct.SearchesDefaults.numberOfPhotosColumns {
    didSet{
      ConstantsStruct.SearchesDefaults.numberOfPhotosColumns = numberOfPhotosColumns
      needCalculateItemSize = true
      self.calculateItemSize()
    }
  }
  
  //добавил протокол и свойство comeBackFromUserDetail  ,   так как при возврате от USER Detail система автоматически ставит navigationBar ( даже если он не виден - все равно isHidden == false ) и в результате на  phone X все съезжает collectionView frame из-за того что обнуляется свойство collectionView?.frame.origin.y == 0.0 когда в портрете
  var comeBackFromUserDetail = false
  
  func setComeBackFromUserDetailToTrue() { comeBackFromUserDetail = true }
  
  private func itemWidthFor(newNumberOfPhotosColumns : Int) -> CGFloat {
    let superViewBounds = foundUsersCollectionView.superview!.bounds
    let minBoundsSize = superViewBounds.height > superViewBounds.width ? superViewBounds.width : superViewBounds.height
    
    return minBoundsSize / CGFloat( newNumberOfPhotosColumns)
  }
  
  private func calculateItemSize() {
    
    if needCalculateItemSize == false {
      return
    }
    needCalculateItemSize = false
    
    itemWidth = itemWidthFor(newNumberOfPhotosColumns: numberOfPhotosColumns)
    
    //    let superViewBounds = foundUsersCollectionView.superview!.bounds
    //    let minBoundsSize = superViewBounds.height > superViewBounds.width ? superViewBounds.width : superViewBounds.height
    //
    //    itemWidth = minBoundsSize / CGFloat( numberOfPhotosColumns)
    
    let layout  = foundUsersCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
    UIView.animate(withDuration:   ConstantsStruct.Durations.pinchCellResizeInSeconds)
    {
      print("====> ДО ИЗМЕНЕНИЯ self.foundUsersCollectionView.contentOffset.y = \(self.foundUsersCollectionView.contentOffset.y)")
      layout.itemSize = CGSize(width: self.itemWidth, height: self.itemWidth)
     self.setShowNavBarIfFirstPageContainsAllCells()
     self.recalculateConstraints_And_FirstCell_And_OffsetY_WhenBoundsChangeOrItemWidthChanges()
    }
  }
  
  var cvp_numberOfColumnsForCurrentDeviceOrientation: Int {
    let freeSpace = foundUsersCollectionView.superview!.bounds.width - max(UIApplication.shared.keyWindow!.safeAreaInsets.right, UIApplication.shared.keyWindow!.safeAreaInsets.left)
    
    //print(".superview!.bounds.width=\(foundUsersCollectionView.superview!.bounds.width), max(.safeAreaInsets.right, left)=\(max(UIApplication.shared.keyWindow!.safeAreaInsets.right, UIApplication.shared.keyWindow!.safeAreaInsets.left)), freeSpace=\(freeSpace), numberOfColumns=\(Int( floor( freeSpace / itemWidth)))")
    
    return Int( floor( freeSpace / itemWidth))
  }
  
  var cvp_maxAllowableCollectionViewHeight : CGFloat {
    return  foundUsersCollectionView.superview!.bounds.height -  cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight
  }
  
  var cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight: CGFloat {
    var cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight: CGFloat = 0.0
    
    if let navigationBar = self.navigationController?.navigationBar {
     cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight =  navBarIsHidden ?  UIApplication.shared.keyWindow!.safeAreaInsets.top : navigationBar.frame.height + UIApplication.shared.statusBarFrame.height + searchBar.frame.height
    } else {
      cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight =  0.0
    }
    
    print("cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight = \(cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight)")
    
    return cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight
  }
  
  var cvp_numberOfRowsForCurrentDeviceOrientation: Int {
    return Int(floor( (cvp_maxAllowableCollectionViewHeight + itemWidth * ConstantsStruct.Sizes.maxPortionOfCellHeightThatCanBeClipped ) /  itemWidth ))
  }
  
  var cvp_heightOfAllVisibleRows: CGFloat {return  CGFloat( cvp_numberOfRowsForCurrentDeviceOrientation )  *  itemWidth }
  
  var cvp_numberOfRowsAboveFirstVisibleCell: CGFloat { return floor(CGFloat( firstVisibleCellNumber) / CGFloat( cvp_numberOfColumnsForCurrentDeviceOrientation)) }
  
  var cvp_currentPageOffset_Y: CGFloat { return   cvp_numberOfRowsAboveFirstVisibleCell * itemWidth }
  
  var cvp_numberOfVeryLastCell : Int { return max(0,(foundUsers?.count ?? 0) - 1)  }
  
  var cvp_maxPossibleNumberOfVisibleCellsOnPage : Int  { return cvp_numberOfColumnsForCurrentDeviceOrientation * cvp_numberOfRowsForCurrentDeviceOrientation }
  
  var wasFirstCalculationOf_FirstVisibleCellNumber = false
  
  private func calculateFirstVisibleCellNumber_and_OffsetY_ifNeeded()
  {
    
    if let isUp = pageWillBeTurnedUp {
     if isUp {
         firstVisibleCellNumber = min(cvp_numberOfVeryLastCell , lastVisibleCellNumber + 1)
       } else // down
      {
        firstVisibleCellNumber = cvp_maxPossibleNumberOfVisibleCellsOnPage >= firstVisibleCellNumber ? 0 : firstVisibleCellNumber - cvp_maxPossibleNumberOfVisibleCellsOnPage
       }
      
    } else // pageWillBeTurnedUp == nil
    {
     if scrollViewShouldScrollToTop_JustHappens {
        firstVisibleCellNumber = 0
        scrollViewShouldScrollToTop_JustHappens = false
      } else {
         if let  firstVisibleCellIndexPath = foundUsersCollectionView.indexPathForItem(at: CGPoint(x: foundUsersCollectionView.contentOffset.x  + itemWidth /  2.0 , y: foundUsersCollectionView.contentOffset.y +  itemWidth /  2.0 ))    {
             if firstVisibleCellNumber != firstVisibleCellIndexPath.item {
                 //значит скорее всего поворот или измененился  size class
            //значит нужно вернуться к firstVisibleCellNumber как  был до поворота то есть текщее значение firstVisibleCellNumber - мы актулизируем так
            UIView.animate(withDuration: ConstantsStruct.Durations.correctContentOffsetForPinchOrRotate) {
              self.foundUsersCollectionView.contentOffset.y =  self.observeSettingNewContentOffsetY(to: self.cvp_numberOfRowsAboveFirstVisibleCell * self.itemWidth)
              self.firstVisibleCellNumber = Int( self.cvp_numberOfRowsAboveFirstVisibleCell * CGFloat( self.cvp_numberOfColumnsForCurrentDeviceOrientation) )
                   }
          }
        }
      }
    }
    pageWillBeTurnedUp = nil
  }
  
  var firstVisibleCellNumber = -1
  {
    didSet{
      lastVisibleCellNumber = min( firstVisibleCellNumber + cvp_maxPossibleNumberOfVisibleCellsOnPage - 1,cvp_numberOfVeryLastCell)
      wasFirstCalculationOf_FirstVisibleCellNumber = true
      print("firstVisibleCellIndexPath FROM calculateNewCollectionFrameOrigin_and_CollectionFrame = \(firstVisibleCellNumber + 1)")
      print("lastVisibleCellIndexPath FROM calculateNewCollectionFrameOrigin_and_CollectionFrame = \(lastVisibleCellNumber + 1)")
      //      previousFirstVisibleCellNumber = oldValue
    }
  }
  
  var lastVisibleCellNumber = 0
  
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
        self?.firstVisibleCellNumber = 0
        self?.calculateFirstVisibleCellNumber_and_OffsetY_ifNeeded()
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
  
  
  var searchParameters: [String: Any]?
  var searchBarBoundsY: CGFloat = 0.0
  
  
  @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var collectionLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
  
  
  @IBOutlet weak var foundUsersCollectionView: UICollectionView!
  
  var  maxZoomingScale: CGFloat = 0.0
  var  minZoomingScale: CGFloat = 0.0
  
  //private var  currentPinchState: UIGestureRecognizerState = .ended
  
  @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
    
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
     let newNumberOfPhotosColumns  = min(ConstantsStruct.SearchParameters.maxNumberOfColumns ,max( numberOfPhotosColumns + ( difMin > difMax ? 1 : -1) , 1))
     let newItemWidth = itemWidthFor(newNumberOfPhotosColumns: newNumberOfPhotosColumns)
     if (newItemWidth + ConstantsStruct.Sizes.constraintTolerance) < cvp_maxAllowableCollectionViewHeight   { // высота фото не должна быть болььше высоты коллешн]вью
         numberOfPhotosColumns = newNumberOfPhotosColumns
       }
     //print(" difMax = \(difMax), difMin = \(difMin)")
    }
    sender.scale = 1
  }
  
  let nameOf_contentOffset_keyPath = "contentOffset"
  //  let nameOf_contentInset_keyPath =  "contentInset"
  let nameOf_bounds_keyPath = "bounds"
  
  private func recalculateConstraints_And_FirstCell_And_OffsetY_WhenBoundsChangeOrItemWidthChanges() {
    constraints()
    
    pageWillBeTurnedUp = nil
    
    calculateFirstVisibleCellNumber_and_OffsetY_ifNeeded()
  }
  
  var oldBoundsWidth: CGFloat = 0.0 {
    didSet{
    recalculateConstraints_And_FirstCell_And_OffsetY_WhenBoundsChangeOrItemWidthChanges()
    print("old oldBoundsWidth = \(oldValue),  oldBoundsWidth = \(oldBoundsWidth)")
    }
  }
  
  func getLeadingOrTrailingConstraintConstantForLandscapeUsing(leftOrRightSafeInset inset: CGFloat) -> (mainConstant: CGFloat, constantIfThereIsNoNotchElseZero: CGFloat )  {
    
    var mainConstant =   max(inset,  foundUsersCollectionView.superview!.bounds.width - CGFloat( cvp_numberOfColumnsForCurrentDeviceOrientation) * itemWidth )
    
    //    print("result = \(mainConstant), safe inset = \(inset), superview!.bounds.width -  numberOfColumn * itemWidth= \(foundUsersCollectionView.superview!.bounds.width - CGFloat( cvp_numberOfColumnsForCurrentDeviceOrientation) * itemWidth )")
    
    mainConstant = max(0.0, mainConstant -  ConstantsStruct.Sizes.constraintTolerance)
    var constantIfThereIsNoNotchElseZero: CGFloat = 0.0
    if inset == 0.0 { // if there is no notch iphone X, them make it in center
      mainConstant =  mainConstant /  2.0
      constantIfThereIsNoNotchElseZero = mainConstant
    }
    
    return ( mainConstant, constantIfThereIsNoNotchElseZero )
    
  }
  
  private func makePortraitConstants() {
    print("Portrait")
    collectionLeadingConstraint?.constant = 0.0
    collectionTrailingConstraint?.constant = 0.0
  }
  
  private func makeLandscapeConstantsFor(left: Bool) {
    
    if left {
     let result = getLeadingOrTrailingConstraintConstantForLandscapeUsing(leftOrRightSafeInset: UIApplication.shared.keyWindow!.safeAreaInsets.right )
      collectionLeadingConstraint?.constant  = result.mainConstant
      collectionTrailingConstraint?.constant = result.constantIfThereIsNoNotchElseZero // if safe area == 0 then not iphone X
     print("Landscape Left")
      
    } else {
      let result = getLeadingOrTrailingConstraintConstantForLandscapeUsing(leftOrRightSafeInset: UIApplication.shared.keyWindow!.safeAreaInsets.left)
      collectionLeadingConstraint?.constant  = result.constantIfThereIsNoNotchElseZero
      collectionTrailingConstraint?.constant = result.mainConstant
     print("Landscape Right")
    }
    
  }
  
  private func constraints() {
    
    foundUsersCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
    switch UIDevice.current.orientation {
    case .portrait:
     makePortraitConstants()
      
    case .landscapeLeft:
     makeLandscapeConstantsFor(left: true)
      
    case .landscapeRight:
     makeLandscapeConstantsFor(left: false)
      
    case .portraitUpsideDown:
      makePortraitConstants()
     print("Portrait Upside Down")
    default:
     if foundUsersCollectionView.bounds.width > foundUsersCollectionView.bounds.height {
        makeLandscapeConstantsFor(left: true)
      } else {
        makePortraitConstants()
      }
     print("Unable to Determine State")
    }
    collectionHeightConstraint?.constant = cvp_heightOfAllVisibleRows
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
  
  private var navBarIsHidden = false {
    didSet{
      // navBarIsHidden - выносим в отдельную перемнную так как navigationBat.isHidden - не всегда выдает правильное значение видимо из-за анимации
      // то есть на самом деле он уже начал уибраться но  navigationBat.isHidden =  false, поэтому заводим отдельную переменную navBarIsHidden
      navigationController?.setNavigationBarHidden(navBarIsHidden, animated: navBarIsHidden)
    }
  }
 
  private func setShowHideNavBar( show: Bool) {
    
    
    navBarIsHidden = !show
    //navigationController?.setNavigationBarHidden(!show, animated: !show)
    
    // false - так как уже в нути анимационного блока если поставить true - проблемы будут с расчетом высоты коллекции
    showStatusBar = show
    
    //self.searchBar.isHidden = isUp
    searchBarTopConstraint.constant = !show ? (-navigationController!.navigationBar.frame.height - searchBar.frame.height) * 2   : 0.0
    
  }
  
  private func setShowNavBarIfFirstPageContainsAllCells() {
    if  cvp_numberOfVeryLastCell <=  cvp_maxPossibleNumberOfVisibleCellsOnPage {
      setShowHideNavBar(show: true)
    }
  }
  
  private func setShowHideNavBarAfterPageWasChanged( isUp: Bool) {
    
    // сначала установим видимость или невидимость, чтобы можно быо рассчитать cvp_maxPossibleNumberOfVisibleCellsOnPage и cvp_numberOfVeryLastCell
    self.setShowHideNavBar(show: !isUp)
    
    // а теперь пересчитаем заново и если все ячейки умещаются на первой странице то обязельно выведем навигейшн бар
    self.setShowNavBarIfFirstPageContainsAllCells()
    
  }
  
  private var pageWillBeTurnedUp: Bool? {
    didSet{
     
      UIView.animate(withDuration: 0.5, animations: {
         if let isUp = self.pageWillBeTurnedUp  {
             self.setShowHideNavBarAfterPageWasChanged(isUp: isUp)
           }
         print("!!!!!--BEFORE---- self.collectionHeightConstraint.constant = \(self.collectionHeightConstraint.constant)")
         self.collectionHeightConstraint.constant = self.cvp_heightOfAllVisibleRows
         print("!!!!!---AFTER--- self.collectionHeightConstraint.constant = \(self.collectionHeightConstraint.constant)")
         if self.navigationController!.isNavigationBarHidden {
             self.collectionTopConstraint.constant =  UIApplication.shared.keyWindow!.safeAreaInsets.top == 0.0 ? (self.foundUsersCollectionView.superview!.bounds.height - CGFloat( self.cvp_numberOfRowsForCurrentDeviceOrientation) * self.itemWidth) / 2.0  : 0.0
           } else {
             self.collectionTopConstraint.constant =  ConstantsStruct.Sizes.searchBarHeight
           }
         self.constraints()
         // print("===>>>> self.collectionTopConstraint.constant = \(self.collectionTopConstraint.constant), self.collectionHeightConstraint.constant =\(self.collectionHeightConstraint.constant )")
       }) { (finished: Bool) in
       }
    }
  }
  
  //MARK: Observation
  
  deinit {
    foundUsersCollectionView.removeObserver(self, forKeyPath: nameOf_contentOffset_keyPath)
    foundUsersCollectionView.removeObserver(self, forKeyPath: nameOf_bounds_keyPath)
    //    collectionView.removeObserver(self, forKeyPath: nameOf_contentInset_keyPath)
  }
  
  var lastContentOffset_Y_BeforPageBeginDragging:CGFloat = 0.0
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let keyPath = keyPath, let collectionView = object as? UICollectionView {
     if keyPath == nameOf_contentOffset_keyPath {
         //fixedCollectionViewContentOffsetY = collectionView.contentOffset.y
         if  collectionView.contentOffset.y == 0.0   || !wasFirstCalculationOf_FirstVisibleCellNumber {
          // чтобы когда вернуться тапом на статус баре на самую первую страницу рассчитался бы первый и поседний видимый клетка
          lastContentOffset_Y_BeforPageBeginDragging = 0.0
        }
         //print("----Observation Observation Observation-----collectionView.contentOffset.y = \(collectionView.contentOffset.y)")
         if collectionView.contentOffset.y < -itemWidth / 2.0 {
             recalculateConstraints_And_FirstCell_And_OffsetY_WhenBoundsChangeOrItemWidthChanges()
           }
        } else if keyPath == nameOf_bounds_keyPath {
        if oldBoundsWidth != collectionView.bounds.size.width {
          print(" bounds changed")
          oldBoundsWidth = collectionView.bounds.size.width
        }
      }
    }
  }
  
  //  private var newTargetY: CGFloat = 0.0
  
  //MARK: UIScrollViewDelegate
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
    lastContentOffset_Y_BeforPageBeginDragging = scrollView.contentOffset.y
  }
  
  var scrollViewShouldScrollToTop_JustHappens = false
  
  func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    pageWillBeTurnedUp = nil
    scrollViewShouldScrollToTop_JustHappens = true
    calculateFirstVisibleCellNumber_and_OffsetY_ifNeeded()
    
    return true
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    lastContentOffset_Y_BeforPageBeginDragging = scrollView.contentOffset.y
  }
  
  func observeSettingNewContentOffsetY( to y: CGFloat) -> CGFloat {
    
    print(" ==NEW CONTENT OFFSET ==>  SET contentOffset.y = \(y )")
    return y
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
    let newTargetY = targetContentOffset.pointee.y
    if lastContentOffset_Y_BeforPageBeginDragging != newTargetY {
      if lastContentOffset_Y_BeforPageBeginDragging > newTargetY {
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
     let maxQuantityOfCellsOnNextPage = Int(cvp_numberOfRowsForCurrentDeviceOrientation) * cvp_numberOfColumnsForCurrentDeviceOrientation
     
      if isUp {
         let remainsOfCells = foundUsers!.count - lastVisibleCellNumber - 1
         var newFirstCellNumber = lastVisibleCellNumber + 1
         if remainsOfCells < maxQuantityOfCellsOnNextPage {
          //  значит последняя страница
          let numberOfRowsForAllContentSize = Int( ceil( scrollView.contentSize.height / itemWidth ))
          let numberOfRowsAboveLastPage = numberOfRowsForAllContentSize - cvp_numberOfRowsForCurrentDeviceOrientation
          newFirstCellNumber =   numberOfRowsAboveLastPage  * cvp_numberOfColumnsForCurrentDeviceOrientation
        }
         let numberOfShownRows = CGFloat( ceil(Double(( newFirstCellNumber ) / cvp_numberOfColumnsForCurrentDeviceOrientation)))
        targetContentOffset.pointee.y = observeSettingNewContentOffsetY(to: numberOfShownRows *  itemWidth)
       } else {
         if maxQuantityOfCellsOnNextPage > firstVisibleCellNumber {
          //значит переходим на первую страницу
          targetContentOffset.pointee.y  = observeSettingNewContentOffsetY(to: 0.0)
        } else {
             let numberOfCellsAboveNextPage = firstVisibleCellNumber   - maxQuantityOfCellsOnNextPage
          let numberOfRowsAboveNextPage = ceil(Double(numberOfCellsAboveNextPage  / cvp_numberOfColumnsForCurrentDeviceOrientation))
          targetContentOffset.pointee.y = observeSettingNewContentOffsetY(to: CGFloat(numberOfRowsAboveNextPage) * itemWidth)
           }
      }
    }
    
    calculateFirstVisibleCellNumber_and_OffsetY_ifNeeded()
    
  }
}
extension SearchViewController: UICollectionViewDataSource {
  // MARK: UICollectionViewDataSource
  
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
  
  //
  //  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
  // вместо этого метода меняюм тут: layout.itemSize = CGSize(width: self.itemWidth, height: self.itemWidth)
  //    return CGSize(width: itemWidth, height: itemWidth)
  //  }
  
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
    print("  cv.contentOffset.y = \(Int(cv.contentOffset.y)), cv Height=\(Int(cv.bounds.height)), cv fr origin.y=\(Int(cv.bounds.origin.y)) ")
  }
}
