//
//  SearchCollectionViewController.swift
//  vk6042041
//
//  Created by james404 on 11/08/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import UIKit
import VK_ios_sdk

private let reuseIdentifier = ConstantsStruct.CellIdentifiers.FoundUserCollectionViewCell
// про использование NSCache нашел тут https://stackoverflow.com/questions/37018916/swift-async-load-image
let imageCache = NSCache<NSString, AnyObject>()



class SearchCollectionViewController: UICollectionViewController {
  
  // MARK: Model
  
  // part of our Model
  // Array of Users
  // and corresponds to our collection view
  var foundUsers:[User] = []
  
  
  var usersDataSource: UsersInfo?
  var callResult = ""
  
  
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
      if isViewLoaded   {
        searchForUsers()
      }
    }
  }
  
  // MARK: Updating the Collection view
  private func searchForUsers() {
    
    guard isViewLoaded else {
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
    
    foundUsers.removeAll()
    collectionView?.reloadData()
    
    var request = VKApi.users().search(searchParameters)
    
      if request == nil {
        presentAlert(withTitle: "Предупреждение", withMessage: "не заданы парамеры поиска")
        return
      }
    
      request?.debugTiming = true
      request?.requestTimeout = 10
      request?.execute(resultBlock: { [unowned self] (response) in
      
        //let resultText = "Result: \(String(describing: response))"
        //      print(response?.json as Any  )
        //print(resultText)
        //      let parser = JsonParser(newJson: response?.json)
        //      print(parser ?? "no items")
        //print(response?.json["items"])
        //print(response?.responseString ?? "no") 
        
        var noFoundUsers = true
        
        
        guard let jsonString = response?.responseString ,
          let data = jsonString.data(using: .utf8) ,
          let info = try?  JSONDecoder().decode(UsersInfo.self, from: data) else  {
            return
        }
        
//        if let  info = UsersInfo(jsonString: response?.responseString) {
//        if let  info = try JSONDecoder().decode(UsersInfo.self, from: <#T##Data#>) UsersInfo(jsonString: response?.responseString) {
          self.foundUsers = info.response.items
          
          
          if self.foundUsers.count > 0      {
            noFoundUsers = false
          }
          
          print(self.foundUsers.count)
          
          self.collectionView?.reloadData()
//        }
        
        if noFoundUsers {
          self.presentAlert(withTitle: "Предупреждение", withMessage: "не найдено не одного пользователя по параметрам \(searchParameters)")
        }
        
        
         request = nil
        }, errorBlock: { (error : Error?) in
           request = nil
          
      })
    
    
      
    
  }
  
  // Added after lecture for REFRESHING
  @IBAction func refresh(_ sender: UIRefreshControl) {
    searchForUsers()
  }
 
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
      let  width = (collectionView?.frame.width)! / 3
    let layout  = collectionViewLayout as! UICollectionViewFlowLayout
    layout.itemSize = CGSize(width: width, height: width)
    
         // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    
        searchForUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

 

 

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
  
  deinit {
    //self.callingRequest = nil
  }
 }

// MARK UICollectionViewDataSource
extension SearchCollectionViewController {
  
  override  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return foundUsers.count
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FoundUserCollectionViewCell
    
    // Configure the cell
    cell.user = foundUsers[indexPath.row]
    
    return cell
  }

}


