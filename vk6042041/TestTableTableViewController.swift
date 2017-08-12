//
//  TestTableTableViewController.swift
//  vk6042041
//
//  Created by james404 on 25/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import UIKit
import VK_ios_sdk

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
  let defaultGirlsSearch   = [
    VK_API_AGE_FROM: 22,
    VK_API_AGE_TO: 32,
    VK_API_BIRTH_DAY: 22,
    VK_API_BIRTH_MONTH: 11,
    VK_API_CITY: 1,
    VK_API_COUNTRY:1,
    VK_API_ONLINE:1,
    VK_API_PHOTO:1,
    VK_API_SEX:1,
    VK_API_STATUS:1,
    VK_API_FIELDS: [VK_API_PHOTO, ConstantsStruct.VK_API_FIELDS.VK_API_SEARCH_FIELDS]
  ] as [String : Any]
  
  var labels = [USERS_SEARCH]

    override func viewDidLoad() {
        super.viewDidLoad()
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout ))

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        callMethod(request: VKApi.users().search(defaultGirlsSearch))
        
        
      }
    }
  }
  
  func callMethod( request : VKRequest) {
    self.callingRequest = request
    self.performSegue(withIdentifier: ConstantsStruct.SegueIdentifiers.API_CALL, sender: self)
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
