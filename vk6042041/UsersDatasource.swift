//
//  UsersDatasource.swift
//  vk6042041
//
//  Created by james404 on 04/08/2018.
//  Copyright © 2018 Vladimir Filippov. All rights reserved.
//

import UIKit
import VK_ios_sdk

private let reuseIdentifier = ConstantsStruct.CellIdentifiers.FoundUsersCollectionViewCell


class UsersDatasource: NSObject, UICollectionViewDataSource {
  
  var foundUsers:[User]? = []  {
    didSet {
      collectionVuew?.reloadData()
    }
  }
  weak var collectionVuew: UICollectionView?

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
  
  var searchParameters: [String: Any]? {
    didSet{
      /*if isViewLoaded && (view.window != nil) { //
       (view.window != nil) этот вариант не подойдет
       т.к. searchParameters может изменяться из контролера в котором фильтр поиска изменяется
       */
      searchForUsers(true)
    }
  }
  var lastSearchTime = DispatchTime.now()
 
  // MARK: Updating the Collection view
  func searchForUsers(_ newSearch: Bool = false) {
 
    guard var searchParameters = searchParameters else {
      print(  "Предупреждение: не заданы парамеры поиска")
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
       print( "Предупреждение - не заданы парамеры поиска")
      return
    }
    
    print( "Начанаем новый поиск : \(currentTimeString())")
    
    
    request?.debugTiming = true
    request?.requestTimeout = 10
    request?.execute(resultBlock: { [weak self] (response: VKResponse?) in
      
 
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
       }
      
      request = nil
      } , errorBlock: { (error : Error?) in
        print("error = \(String(describing: error))")
        request = nil
    })
    
  }
 
}
