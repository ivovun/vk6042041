//
//  TestTableTableViewController.swift
//  vk6042041
//
//  Created by james404 on 25/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import UIKit
import VK_ios_sdk

let CVC_USERS_SEARCH = "Collection view users search"

let USERS_SEARCH = "users.search"
let USERS_GET = "users.get"
let FRIENDS_GET = "friends.get"
let AUDIO_GET = "audio.get"
let FRIENDS_GET_FULL = "friends.get with fields"
let USERS_SUBSCRIPTIONS = "Pavel Durov subscribers"
let UPLOAD_PHOTO = "Upload photo to wall"
let UPLOAD_PHOTO_ALBUM = "Upload photo to album"
let UPLOAD_PHOTOS = "Upload several photos to wall"
let TEST_CAPTCHA = "Test captcha"
let CALL_UNKNOWN_METHOD = "Call unknown method"
let TEST_VALIDATION = "Test validation"
let MAKE_SYNCHRONOUS = "Make synchronous request"
let SHARE_DIALOG = "Test share dialog"
let TEST_ACTIVITY = "Test VKActivity"
let TEST_APPREQUEST = "Test app request"

class TestTableTableViewController: UITableViewController {
  
  var callingRequest: VKRequest?
  /*
   age_from =22
   age_to =32
   bday =3
   bmonth =11
   city =1
   country =1
   name =1  // - 'этого нет видимо только для сайта
   online =1
   photo =1
   section =people  // - 'этого нет видимо только для сайта
   sex =1
   status =1
 */
  
  var labels = [USERS_SEARCH, CVC_USERS_SEARCH]

    override func viewDidLoad() {
        super.viewDidLoad()
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout ))

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      performSegue(withIdentifier: ConstantsStruct.SegueIdentifiers.SHOW_COLLECTION_VIEW_SEARCH, sender: nil)

    }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
  }
  
  // MARK: - Navigation
  @objc func logout(sender: Any) {
    VKSdk.forceLogout()
    self.navigationController?.popToRootViewController(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == ConstantsStruct.SegueIdentifiers.API_CALL  {
      let apiTestVC = segue.destination as! ApiCallViewController
      apiTestVC.callingRequest = self.callingRequest
      self.callingRequest = nil
    }  else if segue.identifier == ConstantsStruct.SegueIdentifiers.SHOW_COLLECTION_VIEW_SEARCH {
      if let SVC = segue.destination as? SearchCollectionViewController {
        SVC.searchParameters = ConstantsStruct.SearchesDefaults.SearchParameters
      } else if let SVC2 = segue.destination as? SearchViewController {
        SVC2.searchParameters = ConstantsStruct.SearchesDefaults.SearchParameters
      }
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      
        return labels.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestRow", for: indexPath)

        // Configure the cell...
      let label = cell.viewWithTag(1) as! UILabel
      label.text = labels[indexPath.row]

        return cell
    }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let label = labels[indexPath.row] as String? {
      if label == USERS_SEARCH {
        callMethod(request: VKApi.users().search(ConstantsStruct.SearchesDefaults.SearchParameters), withSegueId: ConstantsStruct.SegueIdentifiers.API_CALL)
        
       
      } else if label == CVC_USERS_SEARCH {
        
        callMethod(request: nil, withSegueId: ConstantsStruct.SegueIdentifiers.SHOW_COLLECTION_VIEW_SEARCH)
   
      }
    }
  }
  
  func callMethod( request : VKRequest?, withSegueId segueId: String) {
    self.callingRequest = request
    self.performSegue(withIdentifier: segueId, sender: self)
  }
  
  
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
