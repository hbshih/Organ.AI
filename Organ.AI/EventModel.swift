//
//  EventModel.swift
//  Organ.AI
//
//  Created by Ben on 2020/2/27.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import Foundation

struct EventModel
{
    
    let Event: [String: [String:String]] = [
        "1":["title":"Hang out with Ather","date":"2020/02/14","time":"15:00-17:00","description":"Be Active","invitees":"Erik"],
        "2":["title":"Hang out with Mai","date":"2020/02/14","time":"19:00-20:00","description":"Be Proud","invitees":"Ather"],
        "3":["title":"Hang out with Erik","date":"2020/02/15","time":"10:00-12:00","description":"Be Humble","invitees":"Ather"]
    ]
   /*
    func lookUpEvent(eventId: String)
    {
        
        
    }
    */
    func getEvents(eventId: String) -> [String: String]?
    {
        
        if let eventDetails = Event[eventId]
        {
            return eventDetails
        }else
        {
            return nil
        }
    }
    
}
