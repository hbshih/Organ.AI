//
//  IncomingTextCell.swift
//  EsoxCustomChatDemo
//
//  Created by Nasrullah Khan  on 11/03/2019.
//  Copyright © 2019 Nasrullah Khan . All rights reserved.
//

import UIKit
import MessageKit
import EventKit

class IncomingTextCell: UICollectionViewCell {
    
    @IBOutlet weak var date_1: UIButton!
    @IBOutlet weak var date_2: UIButton!
    @IBOutlet weak var date_3: UIButton!
    @IBOutlet weak var timeSelector: UIStackView!
    @IBOutlet weak var confirmSelectorView: UIStackView!
    @IBOutlet weak var OutsideView: UIView!
    @IBOutlet weak var InsideView: UIView!
    var selec = ""
    
    var VC: ChatViewController = ChatViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func tap(_ sender: Any) {
        timeSelected(selectedTime: date_1.currentTitle!)
    }
    
    @IBAction func button2(_ sender: Any) {
        timeSelected(selectedTime: date_2.currentTitle!)
    }
    @IBAction func button3(_ sender: Any) {
        timeSelected(selectedTime: date_3.currentTitle!)
    }
    
    @IBAction func confirmSchedule(_ sender: Any) {
        
        var msg = "...let me handle the request..."
        VC.insertMessage(MockMessage(text: msg, user: MockUser(senderId: "ajdsklf", displayName: "Booking Assistant"), messageId: "asjdfkl", date: Date()))
        
        VC.setTypingIndicatorViewHidden(false, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.VC.setTypingIndicatorViewHidden(true, animated: true)
            // Add to calendar and notify participants
            var msg = "Your appointment has been confirmed. I have added the event to your calendar."
            self.VC.insertMessage(MockMessage(text: msg, user: MockUser(senderId: "ajdsklf", displayName: "Booking Assistant"), messageId: "asjdfkl", date: Date()))
            
        }
        
        scenario += 1
        
        if scenario == 3
        {
            scenario = 1
        }
        
        confirmSelectorView.isUserInteractionEnabled = false
        
        let newEvent = EKEvent(eventStore: EventsCalendarManager().eventStore)
        
        if VC.time.count == 1
        {
            let startTime = DateFormatHandler().stringToDate(string_date: VC.time["time"]!)
            print("start time \(startTime)")
            newEvent.startDate = startTime
            newEvent.endDate = startTime.addingTimeInterval(Double(VC.duration)*60.0*60.0)
        }else if VC.time.count == 2
        {
            newEvent.startDate = DateFormatHandler().stringToDate(string_date: VC.time["from"]!)
            newEvent.endDate = DateFormatHandler().stringToDate(string_date: VC.time["to"]!)
        }
        newEvent.title = VC.activity[0]
        newEvent.location = VC.placeholder[0]
        
        print(VC.time)
        print(VC.person)
        print(VC.duration)
        print(VC.activity)
        print(VC.placeholder)
        
        VC.time.removeAll()
        VC.person.removeAll()
        VC.duration = Int()
        VC.activity.removeAll()
        VC.placeholder.removeAll()
        VC.missingVariables = ["time": true, "duration": true, "activity": true, "person": true, "placeholder": true]
        VC.first_message_sent = false
        
        //  EventsCalendarManager().presentEventCalendarDetailModal(event: newEvent)
        
        EventsCalendarManager().addEventToCalendar(event: newEvent) { (error) in
            DispatchQueue.main.async
                {
                    print("done add \(newEvent)")
                    // self.navigationController?.popToRootViewController(animated: true)
                    //      print(newEvent.eventIdentifier.)
            }
        }
        
    }
    @IBAction func cancelTapped(_ sender: Any) {
        //VC.insertMessage(MockMessage(custom: ["T", "Tuesday 6/2 10:00 - 12:00", "Tuesday 6/2 14:00 - 16:00", "Tuesday 6/2 15:30 - 17:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
        
        var timesets = [String]()
        if scenario == 1
                                       {
                                           timesets = ["Tuesday 6/2 12:00 - 14:00", "Tuesday 6/2 12:30 - 14:30", "Tuesday 6/2 15:30 - 17:30"]
                                                                           VC.insertMessage(MockMessage(custom: ["C", "Tuesday 6/2 12:00 - 14:00", "Tuesday 6/2 12:30 - 14:30", "Tuesday 6/2 15:30 - 17:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
                                       }else if scenario == 2
                                       {
                                           timesets = ["Wednesday 6/3 10:00 - 11:00", "Thusday 6/4 12:30 - 13:30", "Friday 6/5 15:30 - 16:30"]
                                                                           VC.insertMessage(MockMessage(custom: ["C", "Wednesday 6/3 10:00 - 11:00", "Thusday 6/4 12:30 - 13:30", "Friday 6/5 15:30 - 16:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
                                       }else
                                       {
                                            timesets = ["Thursday 6/4 10:00 - 11:00", "Thusday 6/4 14:30 - 15:30", "Friday 6/5 11:30 - 12:30"]
                                                                           VC.insertMessage(MockMessage(custom: ["C", "Thursday 6/4 10:00 - 11:00", "Thusday 6/4 14:30 - 15:30", "Friday 6/5 11:30 - 12:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
                                       }
        
        
        confirmSelectorView.isUserInteractionEnabled = false
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //self.time.roundCorners(corners: .topRight, radius: 10)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func timeSelected(selectedTime: String)
    {
        self.selec = selectedTime
        
        switch selec {
        case "Tuesday 6/2 12:00 - 14:00":
            VC.time = ["from": "2020-06-02T12:00:00.000-07:00", "to": "2020-06-02T14:00:00.000-07:00"]
        case "Tuesday 6/2 12:30 - 14:30":
            VC.time = ["from": "2020-06-02T12:30:00.000-07:00", "to": "2020-06-02T14:30:00.000-07:00"]
        case "Tuesday 6/2 15:30 - 17:30":
            VC.time = ["from": "2020-06-02T15:30:00.000-07:00", "to": "2020-06-02T17:30:00.000-07:00"]
        case "Wednesday 6/3 10:00 - 11:00":
            VC.time = ["from": "2020-06-03T10:00:00.000-07:00", "to": "2020-06-03T11:00:00.000-07:00"]
        case "Thusday 6/4 12:30 - 13:30":
            VC.time = ["from": "2020-06-04T12:30:00.000-07:00", "to": "2020-06-04T13:30:00.000-07:00"]
        case "Friday 6/5 15:30 - 16:30":
            VC.time = ["from": "2020-06-05T15:30:00.000-07:00", "to": "2020-06-05T16:30:00.000-07:00"]
        case "Thursday 6/4 10:00 - 11:00":
            VC.time = ["from": "2020-06-04T10:00:00.000-07:00", "to": "2020-06-04T11:00:00.000-07:00"]
        case "Thusday 6/4 14:30 - 15:30":
            VC.time = ["from": "2020-06-04T14:30:00.000-07:00", "to": "2020-06-04T15:30:00.000-07:00"]
        case "Friday 6/5 11:30 - 12:30":
            VC.time = ["from": "2020-06-05T11:30:00.000-07:00", "to": "2020-06-05T12:30:00.000-07:00"]
        default:
            VC.time = VC.time
        }
        
        
        var msg = "So you want to book your meeting with \(VC.person.joined(separator: ",")) at \(selectedTime)?"
        VC.insertMessage(MockMessage(text: msg, user: MockUser(senderId: "ajdsklf", displayName: "Booking Assistant"), messageId: "asjdfkl", date: Date()))
        
        var timesets = [String]()
        if scenario == 1
                                       {
                                           timesets = ["Tuesday 6/2 12:00 - 14:00", "Tuesday 6/2 12:30 - 14:30", "Tuesday 6/2 15:30 - 17:30"]
                                                                           VC.insertMessage(MockMessage(custom: ["C", "Tuesday 6/2 12:00 - 14:00", "Tuesday 6/2 12:30 - 14:30", "Tuesday 6/2 15:30 - 17:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
                                       }else if scenario == 2
                                       {
                                           timesets = ["Wednesday 6/3 10:00 - 11:00", "Thusday 6/4 12:30 - 13:30", "Friday 6/5 15:30 - 16:30"]
                                                                           VC.insertMessage(MockMessage(custom: ["C", "Wednesday 6/3 10:00 - 11:00", "Thusday 6/4 12:30 - 13:30", "Friday 6/5 15:30 - 16:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
                                       }else
                                       {
                                            timesets = ["Thursday 6/4 10:00 - 11:00", "Thusday 6/4 14:30 - 15:30", "Friday 6/5 11:30 - 12:30"]
                                                                           VC.insertMessage(MockMessage(custom: ["C", "Thursday 6/4 10:00 - 11:00", "Thusday 6/4 14:30 - 15:30", "Friday 6/5 11:30 - 12:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
                                       }
        
        
        //VC.insertMessage(MockMessage(custom: ["C", timesets.joined(separator: ",")], user: MockUser(senderId: "C", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
        date_1.isUserInteractionEnabled = false
        date_2.isUserInteractionEnabled = false
        date_3.isUserInteractionEnabled = false
    }
    
}
