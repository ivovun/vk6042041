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
class SearchViewController: UIViewController, UIScrollViewDelegate {
  
  
//  func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//    scrollView.isScrollEnabled = false
//  }
  
//  @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
//  {
//    didSet {
//      pinchGesture.delegate = self
//    }
//  }
  
  // MARK: DataSource
  var foundUsers:[User]? = []  {
    didSet {
      foundUsersCollectionView?.reloadData()
    }
  }
  var lastSearchTime = DispatchTime.now()
  var itIsAFirstApearanceOfTheView = true
   var itemWidth: CGFloat = 0.0 {
    didSet{
      print("-------------------------------------------------------------   --------------------------------------------\n ------new item size: = \(itemWidth)")
      
      let layout  = foundUsersCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
       UIView.animate(withDuration:  ConstantsStruct.Durations.pinchCellResizeInSeconds, animations: {
        self.firstVisibleCellNumber = 0
//        let firstVisibleCellBeforeResize = self.firstVisibleCellNumber
        self.updateCollectionViewConstraints()
//        self.firstVisibleCellNumber = firstVisibleCellBeforeResize
        
        print("====> после  ИЗМЕНЕНИЯ cvp_CurrentCollectionContentOffsetY = \(self.cvp_CurrentCollectionContentOffsetY)")
        layout.itemSize = CGSize(width: self.itemWidth, height: self.itemWidth)
      }) { (finished) in
        if finished {
          self.correctContentOffset_Y_ForFirstCellNumber_ToBeAtUpperEdge()
          self.foundUsersCollectionView.panGestureRecognizer.isEnabled = true
        }
      }
     }
  }
  
  private func checkAndResetBarAndConstraintsAndContentOffsetYAndFiirstCell() {
    // а теперь пересчитаем   если все ячейки умещаются на первой странице то обязельно выведем навигейшн бар
    if   cvp_numberOfVeryLastCell <=   cvp_maxPossibleNumberOfVisibleCellsOnPage && navBarIsHidden == true {
      navBarIsHidden = false
    }
 
  }
  
  
  //MARK: ViewController
  
  lazy var slideInTransitioningDelegate = SlideInPresentationManager()
  

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    foundUsersCollectionView.decelerationRate = foundUsersCollectionView.decelerationRate / 100
    
    foundUsersCollectionView.isPagingEnabled = false
    
    foundUsersCollectionView.delegate = self

    self.navigationController?.hidesBarsOnSwipe = false
    
    
    title = "Users"
    
    searchBar.setImage(UIImage(named: "filter_list_order_sequence_sort_sorting_outline-512.png"), for: .bookmark, state: .normal)
//    searchBar.showsCancelButton = true
    searchBar.delegate = self
    
    let cancelButtonAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
    
    UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes, for: .normal)

//    searchBar.sizeToFit()
    
//    pinchGesture.delegate = self
////    pinchGesture.delaysTouchesBegan = true
//    pinchGesture.cancelsTouchesInView = true
    
    
 
    
    //    searchBarBoundsY = (navigationController?.navigationBar.frame.height ?? 0.0) + UIApplication.shared.statusBarFrame.height
    addCollectionViewObserver()
    
    searchForUsers()
    
    numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth = ConstantsStruct.SearchesDefaults.numberOfPhotosColumns
    
    //foundUsersCollectionView.panGestureRecognizer.delegate = self
    //foundUsersCollectionView.pinchGestureRecognizer?.delegate = self
    

   }
  
 
  override func viewDidLayoutSubviews() {
    correctContentOffset_Y_ForFirstCellNumber_ToBeAtUpperEdge()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if itIsAFirstApearanceOfTheView {
      itIsAFirstApearanceOfTheView = false
      searchForUsers()
    }
  }
  
//  override func viewDidDisappear(_ animated: Bool) {
//    searchBar.resignFirstResponder()
//  }
  
  override var prefersStatusBarHidden: Bool {
    if showStatusBar {
      return false
    }
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == ConstantsStruct.SegueIdentifiers.SHOW_USER_INFO, let row = sender as? Int {
      if let userVC = segue.destination as? UserInfoCollectionViewController {
        userVC.user = foundUsers![row]
      }
    } else if segue.identifier == ConstantsStruct.SegueIdentifiers.SHOW_USERS_FILTER {
      if let filterVC = segue.destination as? UsersFilterViewController {
        
//        if traitCollection.horizontalSizeClass == .compact {
//          slideInTransitioningDelegate.direction = .bottom
//        } else {
//          slideInTransitioningDelegate.direction = .right
//        }
        
        
        slideInTransitioningDelegate.direction = PresentationDirection.getDirection()
        
        filterVC.transitioningDelegate = slideInTransitioningDelegate
        
        filterVC.modalPresentationStyle = .custom
        
      }
    }

  }
  
  // MARK: Sizing
  
  
 
  @IBOutlet weak var pinchGesture: UIPinchGestureRecognizer!
  var numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth  = 0  {
    
    didSet{
      ConstantsStruct.SearchesDefaults.numberOfPhotosColumns = numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth
      
      itemWidth = itemWidthFor(newNumberOfPhotosColumns: numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth)
 
    }
   }
  
 
  
//  //добавил протокол и   setNavBarVisible  ,   так как при возврате от USER Detail система автоматически ставит navigationBar ( даже если он не виден - все равно isHidden == false ) и в результате на  phone X все съезжает collectionView frame из-за того что обнуляется свойство collectionView?.frame.origin.y == 0.0 когда в портрете
//  func setNavBarVisible() {
//    navBarIsHidden = false
//    
//  }
  
  private func itemWidthFor(newNumberOfPhotosColumns : Int) -> CGFloat {
    let superViewBounds = foundUsersCollectionView.superview!.bounds
    let minBoundsSize = superViewBounds.height > superViewBounds.width ? superViewBounds.width : superViewBounds.height
    
    return minBoundsSize / CGFloat( newNumberOfPhotosColumns)
  }
  
 
  var cvp_numberOfColumnsForCurrentDeviceOrientation: Int {
    let freeSpace = foundUsersCollectionView.superview!.bounds.width - max(UIApplication.shared.keyWindow!.safeAreaInsets.right, UIApplication.shared.keyWindow!.safeAreaInsets.left)
    
    //print(".superview!.bounds.width=\(foundUsersCollectionView.superview!.bounds.width), max(.safeAreaInsets.right, left)=\(max(UIApplication.shared.keyWindow!.safeAreaInsets.right, UIApplication.shared.keyWindow!.safeAreaInsets.left)), freeSpace=\(freeSpace), numberOfColumns=\(Int( floor( freeSpace / itemWidth)))")
    
    return Int( floor( freeSpace / itemWidth))
  }
  
  var cvp_maxAllowableCollectionViewHeight : CGFloat {
    return  foundUsersCollectionView.superview!.bounds.height -  (navBarIsHidden ?  UIApplication.shared.keyWindow!.safeAreaInsets.top : cvp_navBarAndStatusAndSearchBarHeight)
  }
  
  var cvp_navBarAndStatusAndSearchBarHeight: CGFloat {
    
    let result: CGFloat = 0.0
    
    if let navigationBar = navigationController?.navigationBar {
      return   navigationBar.frame.height + UIApplication.shared.statusBarFrame.height + searchBar.frame.height
    }
    
    return result
  }
 
  var cvp_numberOfRows_OnPage_ForCurrentDeviceOrientation: Int {
    return max(1,Int(floor( (cvp_maxAllowableCollectionViewHeight + itemWidth * ConstantsStruct.Sizes.maxPortionOfCellHeightThatCanBeClipped ) /  itemWidth )))
  }
  
  var cvp_heightOfAllVisibleRows: CGFloat {return  CGFloat( cvp_numberOfRows_OnPage_ForCurrentDeviceOrientation )  *  itemWidth }
  
  var cvp_numberOfRowsAboveFirstVisibleCell: CGFloat { return floor(CGFloat( firstVisibleCellNumber) / CGFloat( cvp_numberOfColumnsForCurrentDeviceOrientation)) }
  
  var cvp_currentPageOffset_Y: CGFloat { return   cvp_numberOfRowsAboveFirstVisibleCell * itemWidth }
  
  var cvp_numberOfVeryLastCell : Int { return max(0,(foundUsers?.count ?? 0) - 1)  }
  
  var cvp_maxPossibleNumberOfVisibleCellsOnPage : Int  { return cvp_numberOfColumnsForCurrentDeviceOrientation * cvp_numberOfRows_OnPage_ForCurrentDeviceOrientation }
 
  private var _firstVisibleCellNumber = -1 {
    didSet{
 
      //correctContentOffsetForFirstCellNumber()
      
      print("firstVisibleCellNumber   = \(firstVisibleCellNumber + 1)")
      print("cvp_lastVisibleCellNumber  = \(cvp_lastVisibleCellNumber + 1)")
      //      previousFirstVisibleCellNumber = oldValue
    }
  }
  
  private func showNavBar_If_FirstCellNumberIsZero_ForFirstCell(newNumber: Int) {
    if newNumber <= 0 && navBarIsHidden {
      navBarIsHidden = false
    }
  }
  
  private func reduceNewFirstCellNumber_If_It_IsLastPage_ToShowMaximumNumberOfCellsOnPage_For(newFirstCellNumber: Int) -> Int {
    if newFirstCellNumber + cvp_maxPossibleNumberOfVisibleCellsOnPage - 1 >=  cvp_numberOfVeryLastCell   {
      //  значит последняя страница
      let numberOfRowsForAllContentSize = Int(ceil(Float(foundUsers?.count ?? 0) / Float(cvp_numberOfColumnsForCurrentDeviceOrientation)))
      let numberOfRowsAboveLastPage = numberOfRowsForAllContentSize - cvp_numberOfRows_OnPage_ForCurrentDeviceOrientation
      return  numberOfRowsAboveLastPage  * cvp_numberOfColumnsForCurrentDeviceOrientation
    }
    
    return newFirstCellNumber
  }
  
  private var firstVisibleCellNumber: Int
  {
    
    set{
 
      showNavBar_If_FirstCellNumberIsZero_ForFirstCell(newNumber: newValue)
 
      _firstVisibleCellNumber = max(reduceNewFirstCellNumber_If_It_IsLastPage_ToShowMaximumNumberOfCellsOnPage_For(newFirstCellNumber: newValue), 0)
    }
    
    get{
      return _firstVisibleCellNumber
    }
   }
  
  private var cvp_lastVisibleCellNumber : Int {
    return min( firstVisibleCellNumber + cvp_maxPossibleNumberOfVisibleCellsOnPage - 1,cvp_numberOfVeryLastCell)
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
    
    guard let searchParameters = searchParameters else {
      presentAlert(withTitle: "Предупреждение", withMessage: "не заданы парамеры поиска")
      return
    }
    
    sleepIfNeeded(sleepFromTime: lastSearchTime, sleepTime_ms: 500)
    
    lastSearchTime = DispatchTime.now()
    
    if newSearch {
      foundUsers?.removeAll()
    }
    
 
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
        self?.firstVisibleCellNumber = 0
      }
     request = nil
      } , errorBlock: { (error : Error?) in
        print("error = \(String(describing: error))")
        request = nil
    })
  }
  
  var searchParameters: [String: Any]?
  var searchBarBoundsY: CGFloat = 0.0
  //MARK: Outlets
  @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var foundUsersCollectionView: UICollectionView!

  @IBOutlet weak var searchBar: UISearchBar!
  
  
  var  pinchResult:CGFloat = 0.0
  
  //private var  currentPinchState: UIGestureRecognizerState = .ended
  
  @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
    
    if sender.state == .began {
      
      foundUsersCollectionView.panGestureRecognizer.isEnabled = false
      
      pinchResult = 1.0
    }
    else  if sender.state == .changed {
      // если sender.scale > 1  увеличение , иначе уменьшение
      pinchResult += sender.scale - 1
      //print("pinchResult = \(pinchResult), sender.scale=\(sender.scale)")
      
    } else if sender.state == .ended {
      
      foundUsersCollectionView.panGestureRecognizer.isEnabled = true

      
      numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth  = min(ConstantsStruct.SearchParameters.maxNumberOfColumns ,max( numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth + ( pinchResult > 1 ? -1 : 1) , 1))
     }
    sender.scale = 1
  }
  
//  let nameOf_contentOffset_keyPath = "contentOffset"
//  let nameOf_bounds_keyPath = "bounds"
  
 
  private var oldCollectionBoundsWidth: CGFloat = 0.0 {
    didSet{
    pageWillBeTurnedUp = nil
      updateCollectionViewConstraints()
    //recalculateConstraints_And_FirstCell_And_OffsetY_WhenBoundsChangeOrItemWidthChanges()
    print("old oldCollectionBoundsWidth = \(oldValue),  oldCollectionBoundsWidth = \(oldCollectionBoundsWidth)")
    }
  }
  
  private var oldCollectionBoundsHeight: CGFloat = 0.0 {
    didSet {
 
      print("old oldCollectionBoundsHeight = \(oldValue),  oldCollectionBoundsHeight = \(oldCollectionBoundsHeight)")
    }
  }
  
  func getLeadingOrTrailingConstraintConstantForLandscapeUsing(leftOrRightSafeInset inset: CGFloat) -> (constantFor_IphoneX_Notch_side: CGFloat, constantForBottomSide: CGFloat )  {
    
    var constantFor_IphoneX_Notch_side =   max(inset,  foundUsersCollectionView.superview!.bounds.width - CGFloat( cvp_numberOfColumnsForCurrentDeviceOrientation) * itemWidth )
    
    //    print("result = \(mainConstant), safe inset = \(inset), superview!.bounds.width -  numberOfColumn * itemWidth= \(foundUsersCollectionView.superview!.bounds.width - CGFloat( cvp_numberOfColumnsForCurrentDeviceOrientation) * itemWidth )")
    
    constantFor_IphoneX_Notch_side = max(0.0, constantFor_IphoneX_Notch_side -  ConstantsStruct.Sizes.constraintTolerance)
    var constantForBottomSide: CGFloat = 0.0
    if inset == 0.0 { // if there is no notch iphone X, them make it in center
      constantFor_IphoneX_Notch_side =  constantFor_IphoneX_Notch_side /  2.0
      constantForBottomSide = constantFor_IphoneX_Notch_side
    }
    
    return ( constantFor_IphoneX_Notch_side, constantForBottomSide )
    
  }
  
  private func makePortraitConstants() {
    print("Portrait")
    collectionLeadingConstraint?.constant = 0.0
    collectionTrailingConstraint?.constant = 0.0
  }
  
  private func updateLandscapeConstantsFor(left: Bool) {
    
    if left {
     let result = getLeadingOrTrailingConstraintConstantForLandscapeUsing(leftOrRightSafeInset: UIApplication.shared.keyWindow!.safeAreaInsets.right )
      collectionLeadingConstraint?.constant  = result.constantFor_IphoneX_Notch_side
      collectionTrailingConstraint?.constant = result.constantForBottomSide // if safe area == 0 then not iphone X
     print("Landscape Left")
      
    } else {
      let result = getLeadingOrTrailingConstraintConstantForLandscapeUsing(leftOrRightSafeInset: UIApplication.shared.keyWindow!.safeAreaInsets.left)
      collectionLeadingConstraint?.constant  = result.constantForBottomSide
      collectionTrailingConstraint?.constant = result.constantFor_IphoneX_Notch_side
     print("Landscape Right")
    }
    
  }
  
  private func changeSearchAndNavBarsVisibility_If_FirstPageContains_AllCells() {
    //а теперь пересчитаем   если все ячейки умещаются на первой странице то обязельно выведем навигейшн бар
    if   cvp_numberOfVeryLastCell <=   cvp_maxPossibleNumberOfVisibleCellsOnPage &&  navBarIsHidden ==  true {
      navBarIsHidden = false
    }

  }
  
  private func updateCollectionViewConstraints() {
    
    foundUsersCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
    collectionHeightConstraint.constant = cvp_heightOfAllVisibleRows
    if navBarIsHidden {
       collectionTopConstraint.constant =  UIApplication.shared.keyWindow!.safeAreaInsets.top == 0.0 ? ( foundUsersCollectionView.superview!.bounds.height - CGFloat(  cvp_numberOfRows_OnPage_ForCurrentDeviceOrientation) *  itemWidth) / 2.0  : 0.0
    } else {
       collectionTopConstraint.constant =  ConstantsStruct.Sizes.searchBarHeight
    }
    
    switch UIDevice.current.orientation {
    case .portrait:
     makePortraitConstants()
      
    case .landscapeLeft:
     updateLandscapeConstantsFor(left: true)
      
    case .landscapeRight:
     updateLandscapeConstantsFor(left: false)
      
    case .portraitUpsideDown:
      makePortraitConstants()
     print("Portrait Upside Down")
    default:
     if foundUsersCollectionView.bounds.width > foundUsersCollectionView.bounds.height {
        updateLandscapeConstantsFor(left: true)
      } else {
        makePortraitConstants()
      }
     print("Unable to Determine State")
    }
    
    changeSearchAndNavBarsVisibility_If_FirstPageContains_AllCells()
    
 
   }

  //MARK: Observation
  
  private var collectionViewBoundsObservation: NSKeyValueObservation?
  private var collectionViewContentOffsetObservation: NSKeyValueObservation?
  
  func addCollectionViewObserver() {
    /* old variant
     https://www.youtube.com/watch?v=OlpCyPcLSp4
     foundUsersCollectionView.addObserver(self, forKeyPath: nameOf_contentOffset_keyPath, options: [.new, .old], context: nil)
     foundUsersCollectionView.addObserver(self, forKeyPath: nameOf_bounds_keyPath, options: [.new, .old], context: nil)
     */
    
    collectionViewBoundsObservation = foundUsersCollectionView.observe(\.bounds)  { (foundUsersCollectionView, change) in
      if self.oldCollectionBoundsWidth != foundUsersCollectionView.bounds.size.width {
        print(" bounds Width changed")
        self.oldCollectionBoundsWidth = foundUsersCollectionView.bounds.size.width
      }
      
      if self.oldCollectionBoundsHeight != foundUsersCollectionView.bounds.size.height {
        print(" bounds height changed")
        self.oldCollectionBoundsHeight = foundUsersCollectionView.bounds.size.height
      }
    }
    
    collectionViewContentOffsetObservation  = foundUsersCollectionView.observe(\.contentOffset)  { (foundUsersCollectionView, change) in
      //print("----Observation Observation Observation-----cvp_CurrentCollectionContentOffsetY = \(self.cvp_CurrentCollectionContentOffsetY)")
    }
    
  }
  
  var showStatusBar = true {
    didSet{
      setNeedsStatusBarAppearanceUpdate()
      searchBarTopConstraint.constant = !showStatusBar ? -cvp_navBarAndStatusAndSearchBarHeight     : 0.0
      
    }
  }
 
  private var navBarIsHidden = false {
    didSet{
      // navBarIsHidden - выносим в отдельную перемнную так как navigationBat.isHidden - не всегда выдает правильное значение видимо из-за анимации
      // то есть на самом деле он уже начал уибраться но  navigationBat.isHidden =  false, поэтому заводим отдельную переменную navBarIsHidden
      navigationController?.setNavigationBarHidden(navBarIsHidden, animated: navBarIsHidden)
      showStatusBar = !navBarIsHidden
      updateCollectionViewConstraints()
    }
  }
  
  var cvp_printDebug_ParametersString: String {
    return "!!!->>>col TopConstraint=\(collectionTopConstraint.constant), col HeightConstraint=\(collectionHeightConstraint.constant),itemWidth=\(itemWidth),  numberOfRowsFor Orientation=\(cvp_numberOfRows_OnPage_ForCurrentDeviceOrientation),  Offset y=\(cvp_CurrentCollectionContentOffsetY), searchBarTopConstraint=\(searchBarTopConstraint.constant), showStatusBar=\(showStatusBar), navBarIsHidden=\(navBarIsHidden), contentOffset=\(cvp_CurrentCollectionContentOffsetY) "
  }
  
  private var pageWillBeTurnedUp: Bool? {
    didSet{
      
      UIView.animate(withDuration: 0.5, animations: {
        if let isUp = self.pageWillBeTurnedUp  {
          // сначала установим видимость или невидимость, чтобы можно быо рассчитать cvp_maxPossibleNumberOfVisibleCellsOnPage и cvp_numberOfVeryLastCell
          self.navBarIsHidden = isUp
          
        }
        // print("===>>>> self.collectionTopConstraint.constant = \(self.collectionTopConstraint.constant), self.collectionHeightConstraint.constant =\(self. collectionHeightConstraint .constant )")
      }) { (finished: Bool) in
        //self.correctContentOffsetForFirstCellNumber()  
      }
    }
  }
  
  
  
  deinit {
    // old vaariant
//    foundUsersCollectionView.removeObserver(self, forKeyPath: nameOf_contentOffset_keyPath)
//    foundUsersCollectionView.removeObserver(self, forKeyPath: nameOf_bounds_keyPath)
    //    collectionView.removeObserver(self, forKeyPath: nameOf_contentInset_keyPath)
  }
  
  var lastContentOffset_Y_BeforPageBeginDragging:CGFloat = 0.0
  
//  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
//  {
//    if let keyPath = keyPath, let collectionView = object as? UICollectionView {
//      if keyPath == nameOf_contentOffset_keyPath {
//        //fixedCollectionViewContentOffsetY = cvp_CurrentCollectionContentOffsetY
////        if  cvp_CurrentCollectionContentOffsetY == 0.0     {
////          // чтобы когда вернуться тапом на статус баре на самую первую страницу рассчитался бы первый и поседний видимый клетка
////          lastContentOffset_Y_BeforPageBeginDragging = 0.0
////        }
////print("----Observation Observation Observation-----cvp_CurrentCollectionContentOffsetY = \(cvp_CurrentCollectionContentOffsetY)")
////        if cvp_CurrentCollectionContentOffsetY < -itemWidth / 2.0 {
////          recalculateConstraints_And_FirstCell_And_OffsetY_WhenBoundsChangeOrItemWidthChanges()
////        }
//      } else if keyPath == nameOf_bounds_keyPath {
//        if oldCollectionBoundsWidth != collectionView.bounds.size.width {
//          print(" bounds Width changed")
//          oldCollectionBoundsWidth = collectionView.bounds.size.width
//        }
//
//        if oldCollectionBoundsHeight != collectionView.bounds.size.height {
//          print(" bounds height changed")
//          oldCollectionBoundsHeight = collectionView.bounds.size.height
//        }
//      }
//    }
//  }
  
  //  private var newTargetY: CGFloat = 0.0
  
  //MARK: UIScrollViewDelegate
  
  var cvp_CurrentCollectionContentOffsetY: CGFloat {
    get {
      return foundUsersCollectionView.contentOffset.y
    }
    
    set{
      foundUsersCollectionView.contentOffset.y = observeSettingNewContentOffsetY(to: newValue)
      firstVisibleCellNumber = Int(  cvp_numberOfRowsAboveFirstVisibleCell * CGFloat( cvp_numberOfColumnsForCurrentDeviceOrientation) )
    }
  }
  
  private func correctContentOffset_Y_ForFirstCellNumber_ToBeAtUpperEdge() {
    if !foundUsersCollectionView.isDragging && !foundUsersCollectionView.isDecelerating {
      if let  firstVisibleCellIndexPath = foundUsersCollectionView.indexPathForItem(at: CGPoint(x: foundUsersCollectionView.contentOffset.x  + itemWidth /  2.0 , y: cvp_CurrentCollectionContentOffsetY +  itemWidth /  2.0 ))    {
        if firstVisibleCellNumber != firstVisibleCellIndexPath.item {
          //значит скорее всего поворот или измененился  size class
          //значит нужно вернуться к firstVisibleCellNumber как  был до поворота то есть текщее значение firstVisibleCellNumber - мы актулизируем так
          UIView.animate(withDuration: ConstantsStruct.Durations.correctContentOffsetForPinchOrRotate) {
            self.cvp_CurrentCollectionContentOffsetY =  self.observeSettingNewContentOffsetY(to: self.cvp_numberOfRowsAboveFirstVisibleCell * self.itemWidth)
          }
        }
      }
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
    lastContentOffset_Y_BeforPageBeginDragging = scrollView.contentOffset.y
    //print("\(cvp_printDebug_ParametersString)")
    
    correctContentOffset_Y_ForFirstCellNumber_ToBeAtUpperEdge()
    //print("\(cvp_printDebug_ParametersString)")


  }
 
  func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    
    firstVisibleCellNumber = 0
    lastContentOffset_Y_BeforPageBeginDragging = 0.0
    return true
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    lastContentOffset_Y_BeforPageBeginDragging = scrollView.contentOffset.y
  }
  
  func  observeSettingNewContentOffsetY( to y: CGFloat) -> CGFloat {
    
    print(" ==NEW CONTENT OFFSET ==>  SET contentOffset.y = \(y )")
    return y
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
    let lastVisibleCellNumberBeforeEndDragging = cvp_lastVisibleCellNumber
    
    if lastContentOffset_Y_BeforPageBeginDragging != targetContentOffset.pointee.y {
      if lastContentOffset_Y_BeforPageBeginDragging > targetContentOffset.pointee.y {
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
         firstVisibleCellNumber = min(cvp_numberOfVeryLastCell , lastVisibleCellNumberBeforeEndDragging + 1)
        
         let numberOfShownRows = CGFloat( ceil(Double(( firstVisibleCellNumber ) / cvp_numberOfColumnsForCurrentDeviceOrientation)))
        targetContentOffset.pointee.y = observeSettingNewContentOffsetY(to: numberOfShownRows *  itemWidth)
      } else {
        if cvp_maxPossibleNumberOfVisibleCellsOnPage >= firstVisibleCellNumber {
          //значит переходим на первую страницу
          targetContentOffset.pointee.y  = observeSettingNewContentOffsetY(to: 0.0)
        } else {
          let numberOfCellsAboveNextPage = firstVisibleCellNumber   - cvp_maxPossibleNumberOfVisibleCellsOnPage
          let numberOfRowsAboveNextPage = ceil(Double(numberOfCellsAboveNextPage  / cvp_numberOfColumnsForCurrentDeviceOrientation))
          targetContentOffset.pointee.y = observeSettingNewContentOffsetY(to: CGFloat(numberOfRowsAboveNextPage) * itemWidth)
        }
        firstVisibleCellNumber = cvp_maxPossibleNumberOfVisibleCellsOnPage >= firstVisibleCellNumber ? 0 : firstVisibleCellNumber - cvp_maxPossibleNumberOfVisibleCellsOnPage
        
      }
        pageWillBeTurnedUp = nil
    }
    
   }
  

  
}

//test 1 gh

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

extension SearchViewController: UICollectionViewDelegate {
  // MARK: UICollectionViewDelegate
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    performSegue(withIdentifier: ConstantsStruct.SegueIdentifiers.SHOW_USER_INFO, sender: indexPath.row)
  }
}

//MARK: UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
  
  //
  //  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
  // вместо этого метода меняем тут: layout.itemSize = CGSize(width: self.itemWidth, height: self.itemWidth)
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

extension SearchViewController: UISearchBarDelegate {
  func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
    //print("clicked")
    performSegue(withIdentifier: ConstantsStruct.SegueIdentifiers.SHOW_USERS_FILTER, sender: self)
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(false, animated: true)
    
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    print("searchBarCancelButtonClicked")
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    print("searchBarSearchButtonClicked")
  }
}

//extension SearchViewController: UIGestureRecognizerDelegate {
//
//  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//    return false
//
////    if gestureRecognizer is UIPinchGestureRecognizer {
////      return false
////    }
////
////    return true
//  }
//
//
//}

//extension SearchViewController: UIGestureRecognizerDelegate {
//  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//    
////    if gestureRecognizer  == foundUsersCollectionView.panGestureRecognizer {
////      if otherGestureRecognizer == foundUsersCollectionView.panGestureRecognizer {
////        return false
////
////      } else if otherGestureRecognizer == pinchGesture {
////        if pinchGesture.scale != 1 {
////          gestureRecognizer.isEnabled = false
////          gestureRecognizer.isEnabled = true
////        }
////      }
////
////
////    }
//    
////    if gestureRecognizer == pinchGesture {
////      foundUsersCollectionView.panGestureRecognizer.isEnabled = false
////      foundUsersCollectionView.panGestureRecognizer.isEnabled = true
////    }
//    
//    return false
//  }
//}
