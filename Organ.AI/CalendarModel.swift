//
//  CalendarModel.swift
//  Organ.AI
//
//  Created by Ben on 2020/2/27.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import Foundation

struct CalendarModel
{
    
    let Calendar: [String:Any] = ["id":"7129387489123", "event_id": ["1","2","3"], "date_occupied": ["01/02/2020":["15:00-17:00","19:00-20:00"],"01/03/2020":["10:00-12:00"]]]
    
    func lookUpCalendar()
    {
        
    }
    
    func setCalendar()
    {
        
    }
    
    func getCalendar() -> [String:Any]
    {
        return Calendar
    }
    
}
