//
//  UsersFilterViewController.swift
//  vk6042041
//
//  Created by vladimirfilippov on 02/12/2018.
//  Copyright © 2018 Vladimir Filippov. All rights reserved.
//

import UIKit

class UsersFilterViewController: UIViewController, HasSwipeInterractionControllerProperty {
  
  var swipeInteractionController: SwipeInteractionController?


    override func viewDidLoad() {
        super.viewDidLoad()
      
      swipeInteractionController = SwipeInteractionController(viewController: self, direction: PresentationDirection.getDirection())


        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
