//
//  ViewController.swift
//  OEMentionsExample
//
//  Created by Omar Alessa on 24/03/2019.
//  Copyright © 2019 Omar Alessa. All rights reserved.
//

import UIKit
import OEMentions

class MessageViewController: UIViewController, OEMentionsDelegate, UITextViewDelegate {
    
    var time = [String: String]()
    var person = [String]()
    var duration = Int()
    var activity = [String]()
    var placeholder = [String]()
    
    func messageSent(message: String) {
        print("new message \(message)")
        
        
        
        var organAI = OrganAIHandler()
        
        
        organAI.getToken { (str) in
            print(str)
            DispatchQueue.main.async {
                organAI.queryProcessor(token: str, query: message) { (data) in
                    print(data)
                    
                    self.time = data["time"] as! [String: String]
                    self.person = data["person"] as! [String]
                    self.activity = data["activity"] as! [String]
                    self.duration = data["duration"] as! Int
                    self.placeholder = data["placeholder"] as! [String]
                    DispatchQueue.main.async {
                        
                        self.performSegue(withIdentifier: "formsegue", sender: nil)
                        
                    }
                    
                }
                
                
            }
            
            
            
        }
        
        
        
        /*
         DispatchQueue.main.async {
         organAI.getToken { (token) in
         organAI.queryProcessor(token: token, query: textView.text) { (data) in
         print(data)
         }
         }
         }*/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "formsegue"
        {
            if let vc = segue.destination as? NativeEventFormViewController
            {
                if self.activity.count != 0
                {
                    vc.eventData["title"] = self.activity[0]
                }
                
                if self.person.count != 0
                {
                    vc.eventData["participant"] = self.person
                }
                
                if self.placeholder.count != 0
                {
                    vc.eventData["location"] = self.placeholder[0]
                }
                
                
                if self.time.count == 1
                {
                    let startTime = DateFormatHandler().stringToDate(string_date: self.time["time"]!)
                    print("start time \(startTime)")
                    vc.eventData["start"] = startTime
                    vc.eventData["end"] = startTime.addingTimeInterval(Double(self.duration)*60.0*60.0)
                }else if self.time.count == 2
                {
                    vc.eventData["start"] = DateFormatHandler().stringToDate(string_date: self.time["from"]!)
                    vc.eventData["end"] = DateFormatHandler().stringToDate(string_date: self.time["to"]!)
                }
            }
            
        }
    }
    
    
    @IBOutlet weak var myContainer: UIView!
    @IBOutlet weak var myTextView: UITextView!
    
    var oeMentions:OEMentions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let oeObjects = [OEObject(id: 1,name: "Ather Gattami"), OEObject(id: 2,name: "Ben Shih"), OEObject(id: 3,name: "Erik Flores")]
        
        oeMentions = OEMentions(containerView: myContainer, textView: myTextView, mainView: self.view, oeObjects: oeObjects)
        oeMentions.delegate = self
        myTextView.delegate = oeMentions
    }
    
    func mentionSelected(id: Int, name: String) {
        print("id \(id)")
        print("name \(name)")
    }
    
    
    
    
}

