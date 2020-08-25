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
import GTMSessionFetcher


class OnboardingViewController: UIViewController, GIDSignInDelegate{
    
        private let service = GTLRCalendarService()
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
                
        DispatchQueue.main.async {
                    self.service.authorizer = user.authentication.fetcherAuthorizer()
            

                                    let query: GTLRCalendarQuery_CalendarListList = GTLRCalendarQuery_CalendarListList.query()
                query.showHidden = true
                query.showDeleted = true
                self.service.executeQuery(
                    query,
                    delegate: self,
                    didFinish: #selector(self.returnCalendars(ticket:finishedWithObject:error:)))
            print("c1 \(self.calendar_summary)")
        }


        print("c2 \(calendar_summary)")
        
        DispatchQueue.main.async {
            print("c3 \(self.calendar_summary)")
        }
        
      //       self.performSegue(withIdentifier: "pickCalendarSegue", sender: nil)
  //      }

    }
    
    var calendar_summary : [String] = [""]
    var calendar_identifier: [String] = [""]
    

    @objc
    func returnCalendars(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_CalendarList,
        error : NSError?) {
        
        calendar_summary.removeAll()
        calendar_identifier.removeAll()
        
        if let error = error {
            print("return calendar failed")
            print(error)
            
           // delegate?.returnedError(error: CustomError(error.localizedDescription))
            return
        }
        if let calendars = response.items, !calendars.isEmpty {
            
            
            
            for calendar in calendars
            {
                calendar_summary.append(calendar.summary!)
                calendar_identifier.append(calendar.identifier!)
                
                print(calendar_summary)
            }
            

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "pickCalendarSegue", sender: nil)
            }
            
            
           // fetchEvents(calendarID: calendars[5].identifier!)
            
        } else {
            //delegate?.returnedError(error: "You need a Google Calendar for this app to work")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "pickCalendarSegue"
       {
        if let vc = segue.destination as? ImportCalendarEventsViewController
        {
            print(calendar_summary)
            
            vc.CalendarList = calendar_summary
            vc.CalendarID = calendar_identifier
            vc.service = service
        }
        }
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        EventsCalendarManager().checkCalendarAuthorization {
        //   self.performSegue(withIdentifier: "homeSegue", sender: nil)
        }
    }
    
    @IBAction func checkAccess(_ sender: Any) {
        EventsCalendarManager().checkCalendarAuthorization {
            self.performSegue(withIdentifier: "homeSegue", sender: nil)
        }
    }
    
    
  //  weak var holding: HoldingController?
    @IBAction func googleCalendarAccess(_ sender: Any) {
        if (GIDSignIn.sharedInstance()?.hasPreviousSignIn())!
        {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        }else
        {
            GIDSignIn.sharedInstance()?.signIn()
        }
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
