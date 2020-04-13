//
//  StringExt.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 8/10/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

extension String {
    
    static func setCustom(string: Date) -> String {
        
        let str = DateFormatHandler().stringToDate(string_date: "2020-04-20T04:00:00.000-07:00")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: str)
    }
    
    static func mediumDateShortTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    static func mediumDateNoTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    static func fullDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        return dateFormatter.string(from: date)
    }
}
