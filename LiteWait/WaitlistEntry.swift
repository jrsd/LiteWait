//
//  WaitlistEntry.swift
//  LiteWait
//
//  Created by mhat on 7/24/15.
//  Copyright (c) 2015 mhat. All rights reserved.
//

import Foundation
import CoreData

class WaitlistEntry: NSManagedObject {
    
    @NSManaged var adults: NSNumber
    @NSManaged var name: String
    @NSManaged var kids: NSNumber
    @NSManaged var totalGuests: NSNumber
    @NSManaged var checkInTime: Date
    @NSManaged var quotedTime: NSNumber
    @NSManaged var seatingPreference: String
    @NSManaged var notes: String
    @NSManaged var phoneNumber: String?
    @NSManaged var emailAddress: String?
    
    @NSManaged var seatedAtTime: Date?
    @NSManaged var isReservation: NSNumber
    @NSManaged var isCallIn: NSNumber
    @NSManaged var isCheckedIn: NSNumber
    @NSManaged var isSeated: NSNumber
    @NSManaged var isRemoved: NSNumber
    @NSManaged var isNoShow: NSNumber
    @NSManaged var noShowTime: Date?
    
    func seat() {
        isSeated = NSNumber(value: true as Bool)
        isRemoved = NSNumber(value: false as Bool)
        isNoShow = NSNumber(value: false as Bool)
        //isCallIn = NSNumber(bool: false)
        seatedAtTime = Date()
    }
    
    func activate() {
        isCheckedIn = NSNumber(value: true as Bool)
        isSeated = NSNumber(value: false as Bool)
        isRemoved = NSNumber(value: false as Bool)
        isNoShow = NSNumber(value: false as Bool)
        //isCallIn = NSNumber(bool: false)
    }
    
    func remove() {
        isSeated = NSNumber(value: false as Bool)
        isRemoved = NSNumber(value: true as Bool)
        isNoShow = NSNumber(value: false as Bool)
        isCheckedIn = NSNumber(value: true as Bool)
        //isCallIn = NSNumber(bool: false)
        seatedAtTime = nil
    }
    
    func unseat() {
        isSeated = NSNumber(value: false as Bool)
        isRemoved = NSNumber(value: false as Bool)
        isNoShow = NSNumber(value: false as Bool)
        //isCallIn = NSNumber(bool: false)
        seatedAtTime = nil
    }
    
    func noShow() {
        isNoShow = NSNumber(value: true as Bool)
    }
    
    func undelete() {
        unseat()
    }
    
    func addNote(_ note: String) {
        notes += "\n"
        notes += note
    }
   
    func getCheckInTime() -> String {
        let formatter = dateFormatter()
        
        let time = formatter.string(from: self.checkInTime)
        
        return time
    }
    
    func getSeatedTime() -> String? {
        let formatter = dateFormatter()
        
        if seatedAtTime != nil {
            let time = formatter.string(from: self.seatedAtTime!)
            return time
        } else {
            return nil
        }
    }
    
    func getQuotedTime() -> String {
        var timeString = ""
        
        if isReservation.boolValue {
            timeString = "Reservation"
        } else if quotedTime.intValue < 60 {
            timeString = "\(quotedTime.intValue) Minutes"
        } else if quotedTime.intValue == 60 {
            timeString = "1 Hour"
        } else {
            timeString = "1 Hour \(quotedTime.intValue - 60) minutes"
        }
        
        return timeString
    }
    
    func getNoShowTime() -> String? {
        let formatter = dateFormatter()
        
        if noShowTime != nil {
            let time = formatter.string(from: self.noShowTime!)
            return time
        } else {
            return nil
        }
    }
    
    func getGuestNumberText() -> String {
        var text = ""
        let adts = adults.intValue
        let kds = kids.intValue
        
        if adts == 0 && kds == 1 {
            text = "\(kds) Child"
        } else if adts == 1 && kds == 0 {
            text = "\(adts) Adult"
        } else if adts == 1 && kds == 1 {
            text = "\(adts) Adult / " + "\(kds) Child"
        } else if adts > 1 && kds == 1 {
            text = "\(adts) Adults / " + "\(kds) Child"
        } else if adts == 1 && kds > 1 {
            text = "\(adts) Adult / " + "\(kds) Children"
        } else if adts > 1 && kds == 0 {
            text = "\(adts) Adults"
        } else if adts == 0 && kds > 1 {
            text = "\(kds) Children"
        } else {
            text = "\(adts) Adults / " + "\(kds) Children"
        }
        return text
    }
    
    func getTotalWaitTime() -> Int? {
        if seatedAtTime != nil {
            //return difference in minutes (seconds/60)
            let waitTime = seatedAtTime!.timeIntervalSince(checkInTime)
            return Int(round(waitTime / 60))
        } else {
            return nil
        }
    }
    
    func getSeatingImage() -> String {
        switch seatingPreference {
        case "Inside":
            return "InsideSeating"
        case "Outside":
            return "OutsideSeating"
        default:
            return "FirstAvailableSeating"
        }
    }
    
    func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = DateFormatter.Style.short
        formatter.dateFormat = "h:mm a"
        
        return formatter
    }
    
}
