//
//  DateFunctions.swift
//  LarmaClock
//
//  Created by Zhuo Hong Wei on 23/12/15.
//  Copyright © 2015 zhuohongwei. All rights reserved.
//

import Foundation

typealias DateProperty = NSDate -> Bool

enum DayOfWeek: Int {
    case Sunday     = 1
    case Monday     = 2
    case Tuesday    = 3
    case Wednesday  = 4
    case Thursday   = 5
    case Friday     = 6
    case Saturday   = 7
}

func betweenInclusive(begin: DayOfWeek, _ end: DayOfWeek) -> DateProperty {
    return { date in
        switch dayOfWeek(date) {
        case begin.rawValue...end.rawValue: return true
        default: return false
        }
    }
}

func fallsOn(day: DayOfWeek) -> DateProperty {
    return { dayOfWeek($0) == day.rawValue }
}

let isWeekday = betweenInclusive(.Monday, .Friday)
let isSaturday = fallsOn(.Saturday)
let isSunday = fallsOn(.Sunday)
let isFriday = fallsOn(.Friday)

let isMondayToThursday: DateProperty = { isWeekday($0) && !isFriday($0) }
let isToday: DateProperty = { stripTime($0) == today() }
let isTommorrow: DateProperty =  { stripTime($0) == tomorrow() }

typealias GetComponents = NSDate -> NSDateComponents

func components(units: NSCalendarUnit) -> GetComponents {
    return { date in
        let calendar = NSCalendar.currentCalendar()
        return calendar.components(units, fromDate: date)
    }
}

let weekdayComponent = components([.Weekday])
let timeComponents = components([.Hour, .Minute])
let dateComponents = components([.Day, .Month, .Year])

let dayOfWeek = { (date: NSDate) in
    return weekdayComponent(date).weekday
}

let time = { (date: NSDate) -> NSTimeInterval in
    let components = timeComponents(date)
    let (h, m) = (components.hour, components.minute)
    return (NSTimeInterval(h)*60.0 + NSTimeInterval(m))*60.0;
}

typealias TransformDate = NSDate -> NSDate

let stripTime: TransformDate = {
    guard let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents($0)) else {
        fatalError()
    }
    return date
}

func addDays(numberOfDays: Int) -> TransformDate {
    return { date in
        return date.dateByAddingTimeInterval(NSTimeInterval(numberOfDays * 60 * 60 * 24))
    }
}

let mondayAfter: TransformDate = { date in
    switch weekdayComponent(date).weekday {
    case DayOfWeek.Sunday.rawValue:
        return addDays(1)(date)
    case let rest:
        return addDays(9-rest)(date)
    }
}

let saturdayAfter: TransformDate = { date in
    switch weekdayComponent(date).weekday {
    case DayOfWeek.Saturday.rawValue:
        return addDays(7)(date)
    case let rest:
        return addDays(7-rest)(date)
    }
}

let today = { return stripTime(NSDate()) }
let tomorrow = { return addDays(1)(today()) }
let comingMonday = { return mondayAfter(today()) }
let comingSaturday = { return saturdayAfter(today()) }