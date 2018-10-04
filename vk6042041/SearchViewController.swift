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
   var itemWidth: CGFloat = 0.0 {
    didSet{
      print("-------------------------------------------------------------   --------------------------------------------\n ------new item size: = \(itemWidth)")
      
      let layout  = foundUsersCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
      UIView.animate(withDuration:   ConstantsStruct.Durations.pinchCellResizeInSeconds)
      {
        
        self.constraints()
        
        print("====> ДО ИЗМЕНЕНИЯ cvp_CurrentCollectionContentOffsetY = \(self.cvp_CurrentCollectionContentOffsetY)")
        layout.itemSize = CGSize(width: self.itemWidth, height: self.itemWidth)
        
       }
     }
  }
  
  private func checkAndResetBarAndConstraintsAndContentOffsetYAndFiirstCell() {
    // а теперь пересчитаем   если все ячейки умещаются на первой странице то обязельно выведем навигейшн бар
    if   cvp_numberOfVeryLastCell <=   cvp_maxPossibleNumberOfVisibleCellsOnPage && navBarIsHidden == true {
      navBarIsHidden = false
    }
 
  }
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  //MARK: ViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    foundUsersCollectionView.decelerationRate = foundUsersCollectionView.decelerationRate / 100
    
    foundUsersCollectionView.isPagingEnabled = false

    self.navigationController?.hidesBarsOnSwipe = false
    
    title = "Users"
    
    //    searchBarBoundsY = (navigationController?.navigationBar.frame.height ?? 0.0) + UIApplication.shared.statusBarFrame.height
    addCollectionViewObserver()
    
    searchForUsers()
    
    numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth = ConstantsStruct.SearchesDefaults.numberOfPhotosColumns

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
 
  var numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth  = 0  {
    
    didSet{
      ConstantsStruct.SearchesDefaults.numberOfPhotosColumns = numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth
      
      itemWidth = itemWidthFor(newNumberOfPhotosColumns: numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth)
 
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
    
    //print("cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight = \(cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight)")
    
    return cvp_navBarAndStatusAndSearchBarHeightIfTheyVisible_else_safeAreaHeight
  }
  
  var cvp_numberOfRowsForCurrentDeviceOrientation: Int {
    return max(1,Int(floor( (cvp_maxAllowableCollectionViewHeight + itemWidth * ConstantsStruct.Sizes.maxPortionOfCellHeightThatCanBeClipped ) /  itemWidth )))
  }
  
  var cvp_heightOfAllVisibleRows: CGFloat {return  CGFloat( cvp_numberOfRowsForCurrentDeviceOrientation )  *  itemWidth }
  
  var cvp_numberOfRowsAboveFirstVisibleCell: CGFloat { return floor(CGFloat( firstVisibleCellNumber) / CGFloat( cvp_numberOfColumnsForCurrentDeviceOrientation)) }
  
  var cvp_currentPageOffset_Y: CGFloat { return   cvp_numberOfRowsAboveFirstVisibleCell * itemWidth }
  
  var cvp_numberOfVeryLastCell : Int { return max(0,(foundUsers?.count ?? 0) - 1)  }
  
  var cvp_maxPossibleNumberOfVisibleCellsOnPage : Int  { return cvp_numberOfColumnsForCurrentDeviceOrientation * cvp_numberOfRowsForCurrentDeviceOrientation }
 
  private var _firstVisibleCellNumber = -1 {
    didSet{
 
      correctContentOffsetForFirstCellNumber()
      
      print("firstVisibleCellIndexPath FROM calculateNewCollectionFrameOrigin_and_CollectionFrame = \(firstVisibleCellNumber + 1)")
      print("lastVisibleCellIndexPath FROM calculateNewCollectionFrameOrigin_and_CollectionFrame = \(cvp_lastVisibleCellNumber + 1)")
      //      previousFirstVisibleCellNumber = oldValue
    }
  }
  
  private var firstVisibleCellNumber: Int
  {
    
    set{
      _firstVisibleCellNumber = newValue
      
      if firstVisibleCellNumber == 0 && navBarIsHidden {
         navBarIsHidden = false
      }

      let numberOfCellsOnNewPage =  cvp_lastVisibleCellNumber - firstVisibleCellNumber + 1
 
      if numberOfCellsOnNewPage <  cvp_maxPossibleNumberOfVisibleCellsOnPage   {
        //  значит последняя страница
        let numberOfRowsForAllContentSize = Int( ceil( foundUsersCollectionView.contentSize.height / itemWidth ))
        let numberOfRowsAboveLastPage = numberOfRowsForAllContentSize - cvp_numberOfRowsForCurrentDeviceOrientation
        _firstVisibleCellNumber =   numberOfRowsAboveLastPage  * cvp_numberOfColumnsForCurrentDeviceOrientation
      }
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
        self?.firstVisibleCellNumber = -1
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
  
  var  pinchResult:CGFloat = 0.0
  
  //private var  currentPinchState: UIGestureRecognizerState = .ended
  
  @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
    
    if sender.state == .began {
      
      pinchResult = 1.0
    }
    else  if sender.state == .changed {
      // если sender.scale > 1  увеличение , иначе уменьшение
      pinchResult += sender.scale - 1
      print("pinchResult = \(pinchResult), sender.scale=\(sender.scale)")
      
    } else if sender.state == .ended {
      
      numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth  = min(ConstantsStruct.SearchParameters.maxNumberOfColumns ,max( numberOfPhotosColumnsInPortraitForPinchRegulationsToCalculateItemWidth + ( pinchResult > 1 ? -1 : 1) , 1))
     }
    sender.scale = 1
  }
  
  let nameOf_contentOffset_keyPath = "contentOffset"
  let nameOf_bounds_keyPath = "bounds"
  
 
  private var oldCollectionBoundsWidth: CGFloat = 0.0 {
    didSet{
    pageWillBeTurnedUp = nil
      constraints()
    //recalculateConstraints_And_FirstCell_And_OffsetY_WhenBoundsChangeOrItemWidthChanges()
    print("old oldCollectionBoundsWidth = \(oldValue),  oldCollectionBoundsWidth = \(oldCollectionBoundsWidth)")
    }
  }
  
  private var oldCollectionBoundsHeight: CGFloat = 0.0 {
    didSet {
 
      print("old oldCollectionBoundsHeight = \(oldValue),  oldCollectionBoundsHeight = \(oldCollectionBoundsHeight)")
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
    
    collectionHeightConstraint.constant = self.cvp_heightOfAllVisibleRows
    if navBarIsHidden {
       collectionTopConstraint.constant =  UIApplication.shared.keyWindow!.safeAreaInsets.top == 0.0 ? ( foundUsersCollectionView.superview!.bounds.height - CGFloat(  cvp_numberOfRowsForCurrentDeviceOrientation) *  itemWidth) / 2.0  : 0.0
    } else {
       collectionTopConstraint.constant =  ConstantsStruct.Sizes.searchBarHeight
    }
    
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
    
    //а теперь пересчитаем   если все ячейки умещаются на первой странице то обязельно выведем навигейшн бар
    if   cvp_numberOfVeryLastCell <=   cvp_maxPossibleNumberOfVisibleCellsOnPage &&  navBarIsHidden ==  true {
      navBarIsHidden = false
    }
   }
  
 
  func addCollectionViewObserver() {
    //https://www.youtube.com/watch?v=OlpCyPcLSp4
    foundUsersCollectionView.addObserver(self, forKeyPath: nameOf_contentOffset_keyPath, options: [.new, .old], context: nil)
    foundUsersCollectionView.addObserver(self, forKeyPath: nameOf_bounds_keyPath, options: [.new, .old], context: nil)
  }
  
  var showStatusBar = true {
    didSet{
      setNeedsStatusBarAppearanceUpdate()
      searchBarTopConstraint.constant = !showStatusBar ? -(navigationController!.navigationBar.frame.height + searchBar.frame.height) / 2    : 0.0
      
    }
  }
 
  private var navBarIsHidden = false {
    didSet{
      // navBarIsHidden - выносим в отдельную перемнную так как navigationBat.isHidden - не всегда выдает правильное значение видимо из-за анимации
      // то есть на самом деле он уже начал уибраться но  navigationBat.isHidden =  false, поэтому заводим отдельную переменную navBarIsHidden
      navigationController?.setNavigationBarHidden(navBarIsHidden, animated: navBarIsHidden)
      showStatusBar = !navBarIsHidden
      constraints()
    }
  }
  
  var cvp_printDebug_ParametersString: String {
    return "!!!->>>col TopConstraint=\(collectionTopConstraint.constant), col HeightConstraint=\(collectionHeightConstraint.constant),itemWidth=\(itemWidth),  numberOfRowsFor Orientation=\(cvp_numberOfRowsForCurrentDeviceOrientation),  Offset y=\(cvp_CurrentCollectionContentOffsetY), searchBarTopConstraint=\(searchBarTopConstraint.constant), showStatusBar=\(showStatusBar), navBarIsHidden=\(navBarIsHidden) "
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
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
  {
    if let keyPath = keyPath, let collectionView = object as? UICollectionView {
      if keyPath == nameOf_contentOffset_keyPath {
        //fixedCollectionViewContentOffsetY = cvp_CurrentCollectionContentOffsetY
//        if  cvp_CurrentCollectionContentOffsetY == 0.0     {
//          // чтобы когда вернуться тапом на статус баре на самую первую страницу рассчитался бы первый и поседний видимый клетка
//          lastContentOffset_Y_BeforPageBeginDragging = 0.0
//        }
//print("----Observation Observation Observation-----cvp_CurrentCollectionContentOffsetY = \(cvp_CurrentCollectionContentOffsetY)")
//        if cvp_CurrentCollectionContentOffsetY < -itemWidth / 2.0 {
//          recalculateConstraints_And_FirstCell_And_OffsetY_WhenBoundsChangeOrItemWidthChanges()
//        }
      } else if keyPath == nameOf_bounds_keyPath {
        if oldCollectionBoundsWidth != collectionView.bounds.size.width {
          print(" bounds Width changed")
          oldCollectionBoundsWidth = collectionView.bounds.size.width
        }
        
        if oldCollectionBoundsHeight != collectionView.bounds.size.height {
          print(" bounds height changed")
          oldCollectionBoundsHeight = collectionView.bounds.size.height
        }
      }
    }
  }
  
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
  
  private func correctContentOffsetForFirstCellNumber() {
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
    
    correctContentOffsetForFirstCellNumber()


  }
 
  func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    
    firstVisibleCellNumber = 0
    lastContentOffset_Y_BeforPageBeginDragging = 0.0
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
