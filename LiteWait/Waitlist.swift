//
//  Waitlist.swift
//  LiteWait
//
//  Created by mhat on 7/23/15.
//  Copyright (c) 2015 mhat. All rights reserved.
//

import Foundation

enum WaitlistModes {
    case Active, CallIn, Seated, Removed
}

class Waitlist {
    
    var waitlist: [WaitlistEntry]!
    var mode: WaitlistModes!
    var estimatedTime: Int!
    
    init() {
        waitlist = []
        mode = .Active
        estimatedTime = 0
    }
    
    func addEntry(entry: WaitlistEntry) {
        waitlist.append(entry)
    }
    
    func getEntry(index: Int) -> WaitlistEntry {
        let currentList = fetchList()
        return currentList[index]
    }
    
    func getSize() -> Int {
        let currentList = fetchList()
        return currentList.count
    }
    
    func remove(index: Int) {
        waitlist.removeAtIndex(index)
    }
    
    func getCurrentList() -> [WaitlistEntry] {
        return fetchList()
    }
    
    func setMode(setting: WaitlistModes) {
        mode = setting
    }
    
    func getMode() -> WaitlistModes {
        return mode
    }
    
    func fetchList() -> [WaitlistEntry] {
        var relatedEntries = [WaitlistEntry]()
        
        switch mode as WaitlistModes{
        case .CallIn:
            for entry in waitlist {
                if entry.isCheckedIn == false {
                    relatedEntries.append(entry)
                    relatedEntries.sort({$0.checkInTime.compare($1.checkInTime) == NSComparisonResult.OrderedAscending})
                }
            }
        
        case .Seated:
            for entry in waitlist {
                if entry.isSeated == true {
                    relatedEntries.append(entry)
                    relatedEntries.sort({$0.checkInTime.compare($1.checkInTime) == NSComparisonResult.OrderedDescending})
                    
                }
            }
            
        case .Removed:
            for entry in waitlist {
                if entry.isRemoved == true {
                    relatedEntries.append(entry)
                    relatedEntries.sort({$0.checkInTime.compare($1.checkInTime) == NSComparisonResult.OrderedDescending})
                }
            }
            
        default:
            //load all reservations first, then rest of waitlist
            for entry in waitlist {
                if entry.isRemoved != true && entry.isSeated != true  && entry.isReservation == true && entry.isCheckedIn == true{
                    relatedEntries.append(entry)
                }
            }
            for entry in waitlist {
                if entry.isRemoved != true && entry.isSeated != true && !contains(relatedEntries, entry) && entry.isCheckedIn == true {
                    relatedEntries.append(entry)
                }
            }
            relatedEntries.sort({$0.checkInTime.compare($1.checkInTime) == NSComparisonResult.OrderedAscending})
            
        }
        
        return relatedEntries
    }
    
    func getEstimatedTimeString() -> String {
        var timeString = "Current Estimated Wait Time: "
        
        if estimatedTime < 60 {
            timeString += "\(estimatedTime) Minutes"
        } else if estimatedTime == 60 {
            timeString += "1 Hour"
        } else if estimatedTime > 60 && estimatedTime < 120{
            timeString += "1 Hour \(estimatedTime - 60) minutes"
        } else if estimatedTime == 120 {
            timeString += "2 Hours"
        } else {
            timeString += "2 Hours \(estimatedTime - 120) minutes"
        }
        
        return timeString
    }
    
    func getNumberOfActiveParties() -> String {
        var total = 0
        
        for entry in waitlist {
            if entry.isSeated == false && entry.isRemoved == false {
                total += 1
            }
        }
        
        return "Total Parties Waiting: \(total)"
    }
    
}