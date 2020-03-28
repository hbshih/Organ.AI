//
//  OnboardingViewController.swift
//  Organ.AI
//
//  Created by Ben on 2020/3/28.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import UIKit
class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventsCalendarManager().checkCalendarAuthorization {
            self.performSegue(withIdentifier: "segueToHome", sender: nil)
        }
        
        
    }
    @IBAction func checkAccess(_ sender: Any) {
        EventsCalendarManager().checkCalendarAuthorization {
            self.performSegue(withIdentifier: "segueToHome", sender: nil)
        }
    }
    
}
