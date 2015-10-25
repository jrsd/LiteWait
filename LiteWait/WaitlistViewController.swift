//
//  WaitlistViewController.swift
//  LiteWait
//
//  Created by mhat on 7/22/15.
//  Copyright (c) 2015 mhat. All rights reserved.
//

import UIKit
import CoreData

class WaitlistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var newEntryButton: UIButton!
    @IBOutlet weak var pastListsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var dashboardButton: UIButton!
    
    @IBOutlet weak var waitTimeStepper: UIStepper!
    @IBOutlet weak var waitTimeLabel: UILabel!
    
    @IBOutlet weak var numberOfPartiesLabel: UILabel!
    
    var waitlist = Waitlist()
    
    var fetchResultController: NSFetchedResultsController!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.tableView.separatorColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        //round buttons
        newEntryButton.layer.cornerRadius = 10
        settingsButton.layer.cornerRadius = 10
        pastListsButton.layer.cornerRadius = 10
        dashboardButton.layer.cornerRadius = 10
        
        
        //fetch all waitlist entries in local store
        var fetchRequest = NSFetchRequest(entityName: "WaitlistEntry")
        let sortKey = NSSortDescriptor(key: "checkInTime", ascending: true)
        fetchRequest.sortDescriptors = [sortKey]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            var e: NSError?
            var result = fetchResultController.performFetch(&e)
            var entrys = fetchResultController.fetchedObjects as! [WaitlistEntry]
            
            //load all entries into waitlist for management
            for entry in entrys {
                //compare if entry date (
                let formatter = NSDateFormatter()
                formatter.timeStyle = .NoStyle
                formatter.dateStyle = .ShortStyle
                let currentDate = NSDate()
                
                if formatter.stringFromDate(entry.checkInTime) == formatter.stringFromDate(currentDate) {
                    waitlist.addEntry(entry)
                } else {
                    continue
                }
            }
            
            if result != true {
                println(e?.localizedDescription)
            }
            
            waitTimeLabel.text = waitlist.getEstimatedTimeString()
            waitTimeStepper.value = Double(waitlist.estimatedTime)
            numberOfPartiesLabel.text = "Total Parties Waiting: " + "\(waitlist.getSize())"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waitlist.getSize()
    }
        
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "WaitlistEntryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! WaitListTableViewCell
        
        if waitlist.getSize() != 0 {
            var guest = waitlist.getEntry(indexPath.row)
            cell.totalGuestLabel.text = "\(guest.totalGuests.integerValue)"
            cell.nameLabel.text = guest.name
            cell.guestNumberLabel.text = guest.getGuestNumberText()
            cell.checkInTimeLabel.text = guest.getCheckInTime()
            cell.quotedWaitTimeLabel.text = "\(guest.getQuotedTime())"
            cell.seatingPreferenceLabel.text = guest.seatingPreference
            cell.seatingPreferenceImage.image = UIImage(named: guest.getSeatingImage())
            
            if waitlist.getMode() == .Seated {
                var labelText = "Waited \(guest.getTotalWaitTime()!) minutes"
                if guest.notes != "" {
                    labelText += "\n\(guest.notes)"
                }
                cell.notesLabel.text = labelText
            } else {
                cell.notesLabel.text = guest.notes
            }
            
            cell.totalGuestLabel.layer.cornerRadius = 20
            cell.nameLabel.textColor = UIColor.blackColor()
            
            //darken color of totalGuestLabel based on size of party. Blue shades for walk in, green shades for call in
            switch guest.totalGuests {
            case 1, 2:
                if guest.isCallIn == false {
                    cell.totalGuestLabel.backgroundColor = UIColor(red: 173/255, green: 220/255, blue: 255/255, alpha: 1)
                } else {
                    cell.totalGuestLabel.backgroundColor = UIColor(red: 177/255, green: 255/255, blue: 74/255, alpha: 1)
                }
            case 3, 4:
                if guest.isCallIn == false {
                    cell.totalGuestLabel.backgroundColor = UIColor(red: 96/255, green: 187/255, blue: 255/255, alpha: 1)
                } else {
                    cell.totalGuestLabel.backgroundColor = UIColor(red: 160/255, green: 229/255, blue: 74/255, alpha: 1)
                }
            case 5, 6:
                if guest.isCallIn == false {
                cell.totalGuestLabel.backgroundColor = UIColor(red: 82/255, green: 162/255, blue: 222/255, alpha: 1)
                } else {
                    cell.totalGuestLabel.backgroundColor = UIColor(red: 133/255, green: 191/255, blue: 62/255, alpha: 1)
                }
            case 7, 8, 9:
                if guest.isCallIn == false {
                    cell.totalGuestLabel.backgroundColor = UIColor(red: 77/255, green: 150/255, blue: 204/255, alpha: 1)
                } else {
                    cell.totalGuestLabel.backgroundColor = UIColor(red: 89/255, green: 127/255, blue: 41/255, alpha: 1)
                }
            case 10, 11, 12 ,13:
                if guest.isCallIn == false {
                    cell.totalGuestLabel.backgroundColor = UIColor(red: 48/255, green: 94/255, blue: 127/255, alpha: 1)
                } else {
                    cell.totalGuestLabel.backgroundColor = UIColor(red: 44/255, green: 64/255, blue: 21/255, alpha: 1)
                }
            default:
                cell.totalGuestLabel.backgroundColor = UIColor (red: 5/255, green: 9/255, blue: 12/255, alpha: 1)
            }
            
            //if reservation, override total guest label color
            if guest.isReservation == true && waitlist.getMode() == .Active{
                cell.totalGuestLabel.backgroundColor = UIColor(red: 255/255, green: 83/255, blue: 13/255, alpha: 1)
            }
            
            if guest.isNoShow == true && waitlist.getMode() == .Active{
                cell.nameLabel.textColor = UIColor(red: 255/255, green: 83/255, blue: 13/255, alpha: 1)
                cell.notesLabel.text! += "\tNo Show!"
                cell.notesLabel.text! += "\tCalled at \(guest.getNoShowTime()!)"
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("editWaitlistEntry", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var seatPartyAction: UITableViewRowAction!
        var noShowPartyAction: UITableViewRowAction!
        
        switch waitlist.getMode() {
        case .CallIn:
            seatPartyAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Check In",handler: rowSwipe)
        case .Seated:
            seatPartyAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Unseat",handler: rowSwipe)
        case .Removed:
            seatPartyAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Reactivate",handler: rowSwipe)
        default:
            seatPartyAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Seat Party",handler: rowSwipe)
            
            var noShowTitle = "No Show"
            if waitlist.getEntry(indexPath.row).isNoShow == true {
                noShowTitle = "Showed Up"
            }
            
            noShowPartyAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: noShowTitle ,handler: noShow)
            seatPartyAction.backgroundColor = UIColor(red: 189/255, green: 212/255, blue: 222/255, alpha: 1)
            noShowPartyAction.backgroundColor = UIColor(red: 255/255, green: 83/255, blue: 13/255, alpha: 1)
            return [noShowPartyAction, seatPartyAction]
        }
        
        seatPartyAction.backgroundColor = UIColor(red: 189/255, green: 212/255, blue: 222/255, alpha: 1)
        return [seatPartyAction]
    }
    
    //Handle swipe on row, all actions are similar and only very on current waitlist state
    func rowSwipe(action: UITableViewRowAction!, indexPath: NSIndexPath!) {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            let entry = self.waitlist.getEntry(indexPath.row)
            
            switch waitlist.getMode(){
            case .Active:
                entry.seat()
            case .Seated:
                let alertController = UIAlertController(title: "Activate Entry?", message: "Are you sure you want to activate this  entry and send it to the main waitlist?", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: {(action: UIAlertAction!) in entry.unseat()
                self.tableView.reloadData()})
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            case .CallIn:
                entry.activate()
            default:
                let alertController = UIAlertController(title: "Activate Entry?", message: "Are you sure you want to activate this  entry and send it to the main waitlist?", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: {(action: UIAlertAction!) in entry.undelete()
                self.tableView.reloadData()})
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        
            var e: NSError?
            if managedObjectContext.save(&e) != true {
                println("delete error: \(e!.localizedDescription)")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.tableView.reloadData()
            })
            numberOfPartiesLabel.text = waitlist.getNumberOfActiveParties()
        }
    }
    
    func noShow(action: UITableViewRowAction!, indexPath: NSIndexPath!) {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            let entry = self.waitlist.getEntry(indexPath.row)
            
            entry.isNoShow = !entry.isNoShow.boolValue
            
            //create or delete no show time based on whether entry is active
            if entry.isNoShow == true {
                entry.noShowTime = NSDate()
            } else {
                entry.noShowTime = nil
            }
            
            var e: NSError?
            if managedObjectContext.save(&e) != true {
                println("delete error: \(e!.localizedDescription)")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "editWaitlistEntry" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow(){
                let destinationController = segue.destinationViewController as! EditEntryViewController
                
                destinationController.guest = waitlist.getEntry(indexPath.row)
                destinationController.estimatedWaitTime = waitTimeStepper.value
            }
        }
        
        if segue.identifier == "showAddWaitlistEntry" {
            let destinationController = segue.destinationViewController as! AddEntryViewController
            destinationController.estimatedWaitTime = waitTimeStepper.value
        }
    }
    
    @IBAction func activeListButtonPushed(sender: AnyObject) {
        waitlist.setMode(.Active)
        reloadTable()
        titleLabel.text = "Active List"
        
    }
    
    @IBAction func callInListButtonPushed(sender: AnyObject) {
        waitlist.setMode(.CallIn)
        reloadTable()
        titleLabel.text = "Call-In List"
        
    }
    
    @IBAction func seatedListButtonPushed(sender: AnyObject) {
        waitlist.setMode(.Seated)
        reloadTable()
        titleLabel.text = "Seated List"
        
    }
    
    @IBAction func deletedListButtonPushed(sender: AnyObject) {
        waitlist.setMode(.Removed)
        reloadTable()
        titleLabel.text = "Deleted List"

    }
    
    @IBAction func waitTimePickerDidChange(stepper: UIStepper) {
        waitlist.estimatedTime = Int(waitTimeStepper.value)
        waitTimeLabel.text = waitlist.getEstimatedTimeString()
    }
    
    func reloadTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.numberOfPartiesLabel.text = self.waitlist.getNumberOfActiveParties()
            
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
