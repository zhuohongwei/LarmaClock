//
//  Store.swift
//  LarmaClock
//
//  Created by Zhuo Hong Wei on 25/12/15.
//  Copyright © 2015 zhuohongwei. All rights reserved.
//

import Foundation

enum SettingKey: String {
    case Next = "nextalarm"
    case Weekday = "wd"
    case Weekend = "we"
}

typealias Setting = (suppressed: Bool, hour: Int, minute: Int)

typealias GetSetting = SettingKey -> Setting?
typealias SaveSetting = SettingKey -> Setting -> ()

func getSettingFromUserDefaults(userDefaults: NSUserDefaults) -> GetSetting {
    return { key in

        let prefix = key.rawValue

        guard let
            suppressed = userDefaults.objectForKey("\(prefix).suppressed") as? Bool,
            hour = userDefaults.objectForKey("\(prefix).hour") as? Int,
            minute = userDefaults.objectForKey("\(prefix).minute") as? Int else {
                return nil
        }

        return (suppressed, hour, minute)

    }
}

func saveSettingToUserDefaults(userDefaults: NSUserDefaults) -> SaveSetting {
    return { key in
        { setting in

            let prefix = key.rawValue

            userDefaults.setBool(setting.suppressed, forKey: "\(prefix).suppressed")
            userDefaults.setInteger(setting.hour, forKey: "\(prefix).hour")
            userDefaults.setInteger(setting.minute, forKey: "\(prefix).minute")

            userDefaults.synchronize()
        }
    }
}

enum DateKey: String {
    case LastAlarm = "lastalarm.datetime"
    case NextAlarm = "nextalarm.datetime"
}

typealias GetDateTime = DateKey -> NSDate?
typealias SaveDateTime = DateKey -> NSDate -> ()

func getDateTimeFromUserDefaults(userDefaults: NSUserDefaults) ->  GetDateTime {
    return { key in userDefaults.objectForKey(key.rawValue) as? NSDate }
}

func saveDateTimeToUserDefaults(userDefaults: NSUserDefaults) -> SaveDateTime {
    return { key in
        { date in
            userDefaults.setObject(date, forKey: key.rawValue)
            userDefaults.synchronize()
        }
    }
}
