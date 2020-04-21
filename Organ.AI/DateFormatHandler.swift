//
//  DateFormatter.swift
//  Organ.AI
//
//  Created by Ben on 2020/3/13.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import Foundation

struct DateFormatHandler
{
    func dateToFormattedString(date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        let dateString = formatter.string(from: date)
        
        return dateString
    }
    
    func dateToFormattedTimeString(date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let dateString = formatter.string(from: date)
        return dateString
    }
    
    func dayToDayFormattedString(date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"

        let dayString = formatter.string(from: date)
        return dayString
    }
    
    func stringToDate(string_date: String) -> Date
    {
        let dateFormatter = DateFormatter()
        print(string_date)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS-07:00"

      //  dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let formatted_date = dateFormatter.date(from: string_date)
        
        print("formatted \(formatted_date)")
        
        return formatted_date!
    }
    
}
