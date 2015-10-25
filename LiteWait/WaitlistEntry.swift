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
    @NSManaged var checkInTime: NSDate
    @NSManaged var quotedTime: NSNumber
    @NSManaged var seatingPreference: String
    @NSManaged var notes: String
    @NSManaged var phoneNumber: String?
    @NSManaged var emailAddress: String?
    
    @NSManaged var seatedAtTime: NSDate?
    @NSManaged var isReservation: NSNumber
    @NSManaged var isCallIn: NSNumber
    @NSManaged var isCheckedIn: NSNumber
    @NSManaged var isSeated: NSNumber
    @NSManaged var isRemoved: NSNumber
    @NSManaged var isNoShow: NSNumber
    @NSManaged var noShowTime: NSDate?
    
    func seat() {
        isSeated = NSNumber(bool: true)
        isRemoved = NSNumber(bool: false)
        isNoShow = NSNumber(bool: false)
        isCallIn = NSNumber(bool: false)
        seatedAtTime = NSDate()
    }
    
    func activate() {
        isCheckedIn = NSNumber(bool: true)
        isSeated = NSNumber(bool: false)
        isRemoved = NSNumber(bool: false)
        isNoShow = NSNumber(bool: false)
        isCallIn = NSNumber(bool: false)
    }
    
    func remove() {
        isSeated = NSNumber(bool: false)
        isRemoved = NSNumber(bool: true)
        isNoShow = NSNumber(bool: false)
        isCheckedIn = NSNumber(bool: true)
        isCallIn = NSNumber(bool: false)
        seatedAtTime = nil
    }
    
    func unseat() {
        isSeated = NSNumber(bool: false)
        isRemoved = NSNumber(bool: false)
        isNoShow = NSNumber(bool: false)
        isCallIn = NSNumber(bool: false)
        seatedAtTime = nil
    }
    
    func noShow() {
        isNoShow = NSNumber(bool: true)
    }
    
    func undelete() {
        unseat()
    }
    
    func addNote(note: String) {
        notes += "\n"
        notes += note
    }
   
    func getCheckInTime() -> String {
        let formatter = dateFormatter()
        
        let time = formatter.stringFromDate(self.checkInTime)
        
        return time
    }
    
    func getSeatedTime() -> String? {
        let formatter = dateFormatter()
        
        if seatedAtTime != nil {
            let time = formatter.stringFromDate(self.seatedAtTime!)
            return time
        } else {
            return nil
        }
    }
    
    func getQuotedTime() -> String {
        var timeString = ""
        
        if isReservation.boolValue {
            timeString = "Reservation"
        } else if quotedTime.integerValue < 60 {
            timeString = "\(quotedTime.integerValue) Minutes"
        } else if quotedTime.integerValue == 60 {
            timeString = "1 Hour"
        } else {
            timeString = "1 Hour \(quotedTime.integerValue - 60) minutes"
        }
        
        return timeString
    }
    
    func getNoShowTime() -> String? {
        let formatter = dateFormatter()
        
        if noShowTime != nil {
            let time = formatter.stringFromDate(self.noShowTime!)
            return time
        } else {
            return nil
        }
    }
    
    func getGuestNumberText() -> String {
        var text = ""
        var adts = adults.integerValue
        var kds = kids.integerValue
        
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
            let waitTime = seatedAtTime!.timeIntervalSinceDate(checkInTime)
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
    
    func dateFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        formatter.dateFormat = "h:mm a"
        
        return formatter
    }
    
}