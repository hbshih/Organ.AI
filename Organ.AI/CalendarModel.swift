//
//  CalendarModel.swift
//  Organ.AI
//
//  Created by Ben on 2020/2/27.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct CalendarModel
{
    
    let Calendar: [String:Any] = ["id":"7129387489123", "event_id": ["1","2","3"], "date_occupied": ["2020/02/14":["15:00-17:00","19:00-20:00"],"2020/02/15":["10:00-12:00"]]]
    
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
