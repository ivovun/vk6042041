//
//  UserInfoCollectionViewController.swift
//  vk6042041
//
//  Created by james404 on 19/07/2018.
//  Copyright © 2018 Vladimir Filippov. All rights reserved.
//

import UIKit

private let reuseIdentifier = ConstantsStruct.CellIdentifiers.SelectedUserCollectionViewCell

class UserInfoCollectionViewController: UICollectionViewController {
  
  @IBAction func openUserProfile(_ sender: Any) {
//    guard let url =  else {
//      <#statements#>
//    }
  }
  var user: User?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
    self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
   // MARK: - Navigation
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: true)

  }
 
  /*
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   Get the new view controller using [segue destinationViewController].
   Pass the selected object to the new view controller.
   }
   */
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
    // Configure the cell
    
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ConstantsStruct.CellIdentifiers.UserInfoSectionHeaderUICollectionReusableView, for: indexPath) as! UserInfoSectionHeaderUICollectionReusableView
    
    sectionHeaderView.user = user
    let imageView = sectionHeaderView.viewWithTag(ConstantsStruct.LazyTags.tagForCollectionHeaderImageView) as! UIImageView
    imageView.image = kLazyLoadPlaceholderImage
    if let imageURL = user?.photo_200 {
      imageView.addActivityIndicator()
      ImageManager.sharedInstance.downloadImageFromURL(imageURL, emptyCache: false  ) { [weak self] (success, image,imageURL ) -> Void in
        if success && image != nil && self?.user!.photo_200 == imageURL {
          imageView.image = image
          imageView.removeActivitiIndicator()
        }
      }
      
    }
    return sectionHeaderView
   }
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
  
}
