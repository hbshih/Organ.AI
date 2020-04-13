
//
//  OEMentions.swift
//  OEMentions
//
//  Created by Omar Alessa on 7/31/16.
//  Copyright © 2019 omaressa. All rights reserved.
//

import UIKit
import EventKit
import AVFoundation

public protocol OEMentionsDelegate
{
    // To respond to the selected name
    func mentionSelected(id:Int, name:String)
    
}


class OEMentions: NSObject, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // UIViewController view
    var mainView:UIView?
    
    // UIView for the textview container
    var containerView:UIView?
    
    // The UITextView we want to add mention to
    var textView:UITextView?
    
    // List of names to show in the list
    var oeObjects:[OEObject]?
    
    // The list after the query filter
    var theFilteredList = [OEObject]()
    
    // [Index:Length] of added mentions to textview
    var mentionsIndexes = [Int:Int]()
    
    // Keep track if still searching for a name
    var isMentioning = Bool()
    
    // The search query
    var mentionQuery = String()
    
    // The start of mention index
    var startMentionIndex = Int()
    
    // Character that show the mention list (Default is "@"), It can be changed using changeMentionCharacter func
    private var mentionCharater = "@"
    
    // Keyboard hieght after it shows
    var keyboardHieght:CGFloat?
    
    
    // Mentions tableview
    var tableView: UITableView!
    
    //MARK: Customizable mention list properties
    
    // Color of the mention tableview name text
    var nameColor = UIColor.blue
    
    // Font of the mention tableview name text
    var nameFont = UIFont.boldSystemFont(ofSize: 14.0)
    
    // Color if the rest of the UITextView text
    var notMentionColor = UIColor.label
    
    
    // OEMention Delegate
    var delegate:OEMentionsDelegate?
    
    
    
    
    
    var textViewWidth:CGFloat?
    var textViewHieght:CGFloat?
    var textViewYPosition:CGFloat?
    
    var containerHieght:CGFloat?
    
    //MARK: - init
    
    //MARK: class init without container
    public init(textView:UITextView, mainView:UIView, oeObjects:[OEObject]){
        super.init()
        
        self.mainView = mainView
        self.oeObjects = oeObjects
        self.textView = textView
        
        self.textViewWidth = textView.frame.width
        
        initMentionsList()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(OEMentions.keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
    }
    
    //MARK: class init with container
    public init(containerView:UIView, textView:UITextView, mainView:UIView, oeObjects:[OEObject]){
        super.init()
        
        self.containerView = containerView
        self.mainView = mainView
        self.oeObjects = oeObjects
        self.textView = textView
        
        self.containerHieght = containerView.frame.height
        
        self.textViewWidth = textView.frame.width
        self.textViewHieght = textView.frame.height
        self.textViewYPosition = textView.frame.origin.y
        
        initMentionsList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(OEMentions.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    
    //MARK: - UITextView delegate functions:
    var time = [String: String]()
    var person = [String]()
    var duration = Int()
    var activity = [String]()
    var placeholder = [String]()
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.mentionQuery = ""
        self.isMentioning = false
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.isHidden = true
        })
        print(textView.text)
        
        
        var organAI = OrganAIHandler()
        
        
        organAI.getToken { (str) in
            print(str)
            DispatchQueue.main.async {
                organAI.queryProcessor(token: str, query: textView.text) { (data) in
                    print(data)
                    
                    self.time = data["time"] as! [String: String]
                    self.person = data["person"] as! [String]
                    self.activity = data["activity"] as! [String]
                    self.duration = data["duration"] as! Int
                    self.placeholder = data["placeholder"] as! [String]
                    /*           EventsCalendarManager().addEventToCalendar(event: newEvent) { (error) in
                     print(error)
                     }*/
                    

               //     print(DateFormatHandler().stringToDate(string_date: self.time["time"]!))
                    
                    DispatchQueue.main.async {
                 //       let newEvent = EKEvent(eventStore: EventsCalendarManager().eventStore)
                       // newEvent.title = self.activity[0]
                       // newEvent.notes?.append("asdf")
                    
                        
                   //     newEvent.location = "Wee"
                    //     newEvent.location = self.placeholder[0]
                        
                        let keyWindow = UIApplication.shared.connectedScenes
                            .filter({$0.activationState == .foregroundActive})
                            .map({$0 as? UIWindowScene})
                            .compactMap({$0})
                            .first?.windows
                            .filter({$0.isKeyWindow}).first
                        
                        if let rootVC = keyWindow?.rootViewController {
                            
                            let vc = NativeEventFormViewController()
                            vc.eventData["title"] = self.activity[0]
                            vc.eventData["participant"] = self.person[0]
                            vc.eventData["location"] = self.placeholder[0]
                            if self.time.count == 1
                            {
                                var startTime = DateFormatHandler().stringToDate(string_date: self.time["time"]!)
                                print("start time \(startTime)")
                                vc.eventData["start"] = startTime
                                vc.eventData["end"] = startTime.addingTimeInterval(Double(self.duration)*60.0*60.0)
                            }else
                            {
                          //      let t = self.time["time"]!
                                vc.eventData["start"] = DateFormatHandler().stringToDate(string_date: self.time["from"]!)
                                vc.eventData["end"] = DateFormatHandler().stringToDate(string_date: self.time["to"]!)
                            }
                            
                            rootVC.present(vc, animated: true) { 
                                print("complete")
                            }
                        }
                        
                     /*   EventsCalendarManager().presentCalendarModalToAddEvent(event: newEvent) { (Error) in
                            print(Error)
                        }*/
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
    
    public func textViewDidChange(_ textView: UITextView) {
        updatePosition()
    }
    
    
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"
        {
            textView.resignFirstResponder()
        }
        
        let str = String(textView.text)
        var lastCharacter = "nothing"
        
        if !str.isEmpty && range.location != 0{
            lastCharacter = String(str[str.index(before: str.endIndex)])
        }
        
        // Check if there is mentions
        if mentionsIndexes.count != 0 {
            
            for (index,length) in mentionsIndexes {
                
                if case index ... index+length = range.location {
                    // If start typing within a mention rang delete that name:
                    
                    textView.replace(textView.textRangeFromNSRange(range: NSMakeRange(index, length))!, withText: "")
                    mentionsIndexes.removeValue(forKey: index)
                }
                
            }
        }
        
        
        if isMentioning {
            if text == " " || (text.count == 0 &&  self.mentionQuery == ""){ // If Space or delete the "@"
                self.mentionQuery = ""
                self.isMentioning = false
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.tableView.isHidden = true
                    
                })
            }
            else if text.count == 0 {
                self.mentionQuery.remove(at: self.mentionQuery.index(before: self.mentionQuery.endIndex))
                self.filterList(query: self.mentionQuery)
                self.tableView.reloadData()
            }
            else {
                self.mentionQuery += text
                self.filterList(query: self.mentionQuery)
                self.tableView.reloadData()
            }
        } else {
            
            /* (Beginning of textView) OR (space then @) OR (Beginning of new line) */
            if text == self.mentionCharater && ( range.location == 0 || lastCharacter == " " || lastCharacter == "\n") {
                
                self.isMentioning = true
                self.startMentionIndex = range.location
                theFilteredList = oeObjects!
                self.tableView.reloadData()
                UIView.animate(withDuration: 0.2, animations: {
                    self.tableView.isHidden = false
                })
                
            }
        }
        
        return true
    }
    
    
    
    //MARK: - Keyboard will show NSNotification:
    
    @objc public func keyboardWillShow(notification:NSNotification) {
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let thekeyboardHeight = keyboardRectangle.height
        self.keyboardHieght = thekeyboardHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.updatePosition()
            
        })
        
    }
    
    
    
    //MARK: - UITableView deleget functions:
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.theFilteredList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.textLabel!.text = theFilteredList[indexPath.row].name
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addMentionToTextView(name: theFilteredList[indexPath.row].name!)
        
        if delegate != nil {
            self.delegate!.mentionSelected(id: theFilteredList[indexPath.row].id!, name: theFilteredList[indexPath.row].name!)
        }
        
        self.mentionQuery = ""
        self.isMentioning = false
        self.theFilteredList = oeObjects!
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.isHidden = true
        })
    }
    
    // Add a mention name to the UITextView
    public func addMentionToTextView(name: String){
        
        mentionsIndexes[self.startMentionIndex] = name.count
        
        let range: Range<String.Index> = self.textView!.text.range(of: "@" + self.mentionQuery)!
        self.textView!.text.replaceSubrange(range, with: name)
        
        let theText = self.textView!.text + " "
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: theText)
        
        
        // Add color attribute for the whole text
        if let count = self.textView?.text.count {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: notMentionColor, range: NSMakeRange(0, count))
        }
        
        
        // Add color & font attributes for the mention
        for (startIndex, length) in mentionsIndexes {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: nameColor, range: NSMakeRange(startIndex, length))
            attributedString.addAttribute(NSAttributedString.Key.font, value: nameFont, range: NSMakeRange(startIndex, length))
        }
        
        
        // Add color attribute the next text
        if let count = self.textView?.text.count {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: notMentionColor, range: NSMakeRange(count, 1))
        }
        
        
        self.textView!.attributedText = attributedString
        
        updatePosition()
        
    }
    
    //MARK: - Utilities
    
    
    //Mentions UITableView init
    public func initMentionsList(){
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.mainView!.frame.width, height: 100), style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = true
        tableView.separatorColor = UIColor.clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.mainView!.addSubview(self.tableView)
        
        self.tableView.isHidden = true
    }
    
    
    public func filterList(query: String) {
        
        theFilteredList.removeAll()
        
        if query.isEmpty {
            theFilteredList = oeObjects!
        }
        
        if let myOEobjects = oeObjects {
            for object in myOEobjects {
                if object.name?.lowercased().contains(query.lowercased()) ?? false {
                    theFilteredList.append(object)
                }
            }
        }
        
    }
    
    // Set the mention character. Should be one character only, default is "@"
    public func changeMentionCharacter(character: String){
        if character.count == 1 && character != " " {
            self.mentionCharater = character
        }
    }
    
    // Change tableview background color
    public func changeMentionTableviewBackground(color: UIColor){
        self.tableView.backgroundColor = color
    }
    
    // Update views potision for the textview and tableview
    public func updatePosition(){
        
        if containerView != nil {
            
            self.containerView!.frame.size.height = self.containerHieght! + ( self.textView!.frame.height -  self.textViewHieght! )
            self.containerView!.frame.origin.y = UIScreen.main.bounds.height - self.keyboardHieght! - self.containerView!.frame.height
            
            self.textView!.frame.origin.y = self.textViewYPosition!
            
            self.tableView.frame.size.height = UIScreen.main.bounds.height - self.keyboardHieght! - self.containerView!.frame.size.height
        }
        else {
            self.textView!.frame.origin.y = UIScreen.main.bounds.height - self.keyboardHieght! - self.textView!.frame.height
            self.tableView.frame.size.height = UIScreen.main.bounds.height - self.keyboardHieght! - self.textView!.frame.height
        }
        
        
    }
    
}


// OEMentions object (id,name)

public class OEObject {
    
    var id:Int?
    var name:String?
    
    public init(id:Int, name:String){
        self.id = id
        self.name = name
    }
    
}


extension UITextView
{
    public func textRangeFromNSRange(range:NSRange) -> UITextRange?
    {
        let beginning = self.beginningOfDocument
        guard let start = self.position(from: beginning, offset: range.location), let end = self.position(from: start, offset: range.length) else { return nil}
        return self.textRange(from: start, to: end)
    }
}

struct OrganAIHandler
{
    
    var api_response_handler = ["activity": [""], "person": [""], "duration": 0, "time": ""] as [String : Any]
    
    var query = "Book a meeting with @John"
    
    mutating func queryProcessor(token: String, query: String, completion: @escaping ([String:Any]) -> ())
    {
        let sessionConfig = URLSessionConfiguration.default
        let authValue: String? = "Bearer \(token)"
        sessionConfig.httpAdditionalHeaders = ["Authorization": authValue ?? ""]
        
        var _url = URLComponents()
        _url.scheme = "https"
        _url.host = "b50bfdc4.ngrok.io"
        _url.path = "/api/projects/default/logs"
        _url.queryItems = [URLQueryItem(name: "q", value: query)]
        
        if let queryURL = _url.url
        {
            var request = URLRequest(url: queryURL)
            request.httpMethod = "POST"
            let session = URLSession(configuration: sessionConfig)
            
            let sessionTask = session.dataTask(with: request) { (data, response, error) in
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                
                //   print(json)
                var activity = [String]()
                var person = [String]()
                var duration = Int()
                var time = [String: String]()
                var placeholder = [String]()
                
                
                
                if let dict_data = json as? [String: Any] {
                    //  print(dict_data)
                    
                    if let user_input = dict_data["user_input"] as? [String: Any]
                    {
                        //     print(user_input)
                        
                        let seng_msg = user_input["text"] as! String
                        print(seng_msg)
                        
                        //        print(user_input["entities"] as! NSArray)
                        
                        if let entities = user_input["entities"] as? NSArray
                        {
                            //  print(entities)
                            for entity in entities
                            {
                                if let single_entity = entity as? [String: Any]
                                {
                                    //    print(single_entity)
                                    if let entityName = single_entity["entity"] as? String
                                    {
                                        switch entityName {
                                        case "time":
                                            if single_entity["extractor"] as! String == "activityparser"
                                            {
                                                if let time_entity = single_entity["value"] as? [String: String]
                                                {
                                                    time["from"] = time_entity["from"]
                                                    time["to"] = time_entity["to"]
                                                }else
                                                {
                                                    time["time"] = (single_entity["value"] as? String)!
                                                }
                                            }else
                                            {
                                                time["time"] = (single_entity["value"] as? String)!
                                            }
                                        case "activity":
                                            if single_entity["extractor"] as! String == "activityparser"
                                            {
                                                activity.append(single_entity["value"] as! String)
                                            }else
                                            {
                                                if single_entity["extractor"] as! String == "CRFEntityExtractor"
                                                {
                                                    if single_entity["confidence"] as! Double > 0.8
                                                    {
                                                        activity.append(single_entity["value"] as! String)
                                                    }
                                                }
                                            }
                                            
                                        case "PERSON":
                                            if single_entity["extractor"] as! String == "activityparser"
                                            {
                                                person.append(single_entity["value"] as! String)
                                            }else
                                            {
                                                if single_entity["confidence"] as! Double > 0.8
                                                {
                                                    person.append(single_entity["value"] as! String)
                                                }
                                            }
                                        case "duration":
                                            if single_entity["extractor"] as! String == "activityparser"
                                            {
                                                duration = single_entity["value"] as! Int
                                            }else
                                            {
                                                if single_entity["confidence"] as! Double > 0.8
                                                {
                                                    duration = single_entity["value"] as! Int
                                                }
                                            }
                                        case "placeholder":
                                            if single_entity["extractor"] as! String == "RegexEntityExtractor"
                                            {
                                                placeholder.append(single_entity["value"] as! String)
                                            }else
                                            {
                                                if single_entity["extractor"] as! String == "CRFEntityExtractor"
                                                {
                                                    if single_entity["confidence"] as! Double > 0.8
                                                    {
                                                        placeholder.append(single_entity["value"] as! String)
                                                    }
                                                }
                                            }
                                        default:
                                            print("error")
                                        }
                                    }
                                    
                                }
                            }
                            print("\n ########## VALUE ######### \n")
                            print(time)
                            print(activity)
                            print(person)
                            print(duration)
                            print(placeholder)
                            if time.count == 0
                            {
                                print("Ask for Time")
                            }
                            if activity.count == 0
                            {
                                print("Ask for Title")
                            }
                            if person.count == 0
                            {
                                print("Ask for Person")
                            }
                            if duration == 0
                            {
                                print("Ask for Duration")
                            }
                            completion(["time":time, "activity": activity, "person": person, "duration": duration, "placeholder": placeholder])
                        }
                    }
                }
            }
            sessionTask.resume()
        }
    }
    
    func getToken (completion: @escaping (String) -> ())
    {
        guard let url = URL(string: "http://b50bfdc4.ngrok.io/api/auth"),
            let payload = "{\"username\": \"me\", \"password\": \"lRFqAib9zBAe\"}".data(using: .utf8) else
        {
            print("hey")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //  request.addValue("your_api_key", forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print(error!.localizedDescription); return }
            guard let data = data else { print("Empty data"); return }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let dict_token = json as? [String: String] {
                let token = dict_token["access_token"]!
                completion(token)
            }
        }.resume()
    }
    
}

