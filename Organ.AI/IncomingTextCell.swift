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
        
        // Add to calendar and notify participants
        var msg = "Your appointment has been confirmed"
        VC.insertMessage(MockMessage(text: msg, user: MockUser(senderId: "ajdsklf", displayName: "Booking Assistant"), messageId: "asjdfkl", date: Date()))
        
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
        
        msg = "Do you need to arrange any other meeting?"
        VC.insertMessage(MockMessage(text: msg, user: MockUser(senderId: "ajdsklf", displayName: "Booking Assistant"), messageId: "asjdfkl", date: Date()))
        
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
        VC.insertMessage(MockMessage(custom: ["T", "Tuesday 6/2 10:00 - 12:00", "Tuesday 6/2 14:00 - 16:00", "Tuesday 6/2 15:30 - 17:30"], user: MockUser(senderId: "Time", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
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
        var msg = "...let me handle the request..."
        VC.insertMessage(MockMessage(text: msg, user: MockUser(senderId: "ajdsklf", displayName: "Booking Assistant"), messageId: "asjdfkl", date: Date()))
        
        msg = "I have scheduled your appointment at \(selectedTime)"
        VC.insertMessage(MockMessage(text: msg, user: MockUser(senderId: "ajdsklf", displayName: "Booking Assistant"), messageId: "asjdfkl", date: Date()))
        
        VC.insertMessage(MockMessage(custom: ["C", "Tuesday 6/2 10:00 - 12:00", "Tuesday 6/2 14:00 - 16:00", "Tuesday 6/2 15:30 - 17:30"], user: MockUser(senderId: "C", displayName: "Booking Assistant"), messageId: "adsf", date: Date()))
        date_1.isUserInteractionEnabled = false
        date_2.isUserInteractionEnabled = false
        date_3.isUserInteractionEnabled = false
    }
    
}
