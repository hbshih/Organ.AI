//
//  OnboardingViewController.swift
//  Organ.AI
//
//  Created by Ben on 2020/3/28.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST


class OnboardingViewController: UIViewController, GIDSignInUIDelegate{
    

    
    
    

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
    
    
  //  weak var holding: HoldingController?
    @IBAction func googleCalendarAccess(_ sender: Any) {
        
     //   holding?.currentServer = .GOOGLE
      //  holding?.uiDelegate = self
      //  holding?.delegate = self
     //   signInWithServers()
    }
    
    func signInWithServers(){
       // holding?.currentInteractor.signIn(from: self)
    }

    //Sends to the next file
  /*  func changePages()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "chooseOption") as? ChooseExport else {
                return
            }
            nextVC.serverUser = self.holding?.currentInteractor
            nextVC.holder = self.holding
            self.holding?.transition(from: self, to: nextVC, with: .rightToLeft)
        }
    }*/
}
