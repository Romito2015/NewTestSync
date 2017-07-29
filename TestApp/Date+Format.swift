//
//  String+Format.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy, hh:mm:ss a"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        if let date = dateFormatter.date(from: self) {
            return date
        }
        return nil
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, hh:mm"
        return dateFormatter.string(from: self)
    }
}
