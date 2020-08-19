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

class ViewController: UIViewController {

    @IBOutlet weak var videoBackgroundView: UIView!
    
    var videoPlayer:AVPlayer?
    
    var videoPlayerLayer:AVPlayerLayer?
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var login_google: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if Auth.auth().currentUser != nil {
          // User is signed in.
          // ...
            
            performSegue(withIdentifier: "logInAutoSegue", sender: nil)
            
        } else {
          // No user is signed in.
          // ...
        }
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Set up video in the background
        setUpVideo()
        
    }
    
    func setUpElements() {
        
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
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
        
        
    }
    
}

