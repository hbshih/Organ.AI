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
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        EventsCalendarManager().checkCalendarAuthorization {
            self.performSegue(withIdentifier: "homeSegue", sender: nil)
        }
    }
    
    @IBAction func checkAccess(_ sender: Any) {
        EventsCalendarManager().checkCalendarAuthorization {
            self.performSegue(withIdentifier: "homeSegue", sender: nil)
        }
    }
    
}
