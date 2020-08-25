//
//  ViewController.swift
//  CustomLoginDemo
//
//  Created by Christopher Ching on 2019-07-22.
//  Copyright © 2019 Christopher Ching. All rights reserved.
//

import UIKit
import AVKit
import FirebaseAuth
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class ViewController: UIViewController, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
      if let error = error {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
          print("The user has not signed in before or they have since signed out.")
        } else {
          print("\(error.localizedDescription)")
        }
        return
      }
      // Perform any operations on signed in user here.
      let userId = user.userID                  // For client-side use only!
      let idToken = user.authentication.idToken // Safe to send to the server
      let fullName = user.profile.name
      let givenName = user.profile.givenName
      let familyName = user.profile.familyName
      let email = user.profile.email
      // ...
        
        let token = user.authentication.fetcherAuthorizer()
        
        print(familyName)
        print(token)
        
        
        /*
        let query = GTLRCalendarQuery_
        query.maxResults = 10
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))*/
        
        /*
        DispatchQueue.global(qos: .utility).async{
            
            
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            print("fetching calendar")
                   let query: GTLRCalendarQuery_CalendarListList = GTLRCalendarQuery_CalendarListList.query()
                   query.showHidden = true
                   query.showDeleted = true
                   self.service.executeQuery(
                       query,
                       delegate: self,
                       didFinish: #selector(self.returnCalendars(ticket:finishedWithObject:error:)))
               }
        
        
        */
        
    }
    
   
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private let calendarHolder: CalendarHolder? = nil
    private let service = GTLRCalendarService()
    
    @IBAction func getUserCalendar(_ sender: UIButton) {
        
        if !(self.calendarHolder?.calendars.isEmpty ?? true) {
            return
        }
        
        /*
        DispatchQueue.global(qos: .utility).async{
            let query: GTLRCalendarQuery_CalendarListList = GTLRCalendarQuery_CalendarListList.query()
            query.showHidden = true
            query.showDeleted = true
            self.service.executeQuery(
                query,
                delegate: self,
                didFinish: #selector(self.returnCalendars(ticket:finishedWithObject:error:)))
        }
        */
        
        
        
        //getEvents(for: "primary")
    }
    
    fileprivate lazy var calendarService: GTLRCalendarService? = {
        let service = GTLRCalendarService()
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them
        service.shouldFetchNextPages = true
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.isRetryEnabled = true
        service.maxRetryInterval = 15
        
        guard let currentUser = GIDSignIn.sharedInstance().currentUser,
            let authentication = currentUser.authentication else {
                return nil
        }
        
        
        
        service.authorizer = authentication.fetcherAuthorizer()
        return service
    }()
    
    var calendars: [Calendar]?
    
    
    
    @IBOutlet weak var videoBackgroundView: UIView!
    
    var videoPlayer:AVPlayer?
    
    var videoPlayerLayer:AVPlayerLayer?
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var login_google: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            // ...
            
            //   performSegue(withIdentifier: "logInAutoSegue", sender: nil)
            
        } else {
            // No user is signed in.
            // ...
        }
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
      //  GIDSignInDelegate = self
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Set up video in the background
        setUpVideo()
        
    }
    
    func setUpElements() {
        
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleFilledButton(loginButton)
        //        Utilities.styleHollowButton(login_google)
        
    }
    
    func setUpVideo() {
        
        // Get the path to the resource in the bundle
        let bundlePath = Bundle.main.path(forResource: "organai-se", ofType: "mp4")
        
        guard bundlePath != nil else {
            return
        }
        
        // Create a URL from it
        let url = URL(fileURLWithPath: bundlePath!)
        
        // Create the video player item
        let item = AVPlayerItem(url: url)
        
        // Create the player
        videoPlayer = AVPlayer(playerItem: item)
        videoPlayer?.isMuted = true
        
        // Create the layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        
        
        // Adjust the size and frame
        videoPlayerLayer?.frame = CGRect(x: -800, y: -400, width: self.view.frame.size.width * 5, height: self.view.frame.size.height*2)
        
        videoBackgroundView.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        // view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        // Add it to the view and play it
        videoPlayer?.playImmediately(atRate: 1.0)
    }
    
    @IBAction func SignInwithGoogle(_ sender: Any) {
        
        GIDSignIn.sharedInstance()?.signIn()
        
    }
    
}

