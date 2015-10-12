//
//  EditEntryViewController.swift
//  LiteWait
//
//  Created by mhat on 7/22/15.
//  Copyright (c) 2015 mhat. All rights reserved.
//

import UIKit
import MessageUI

class EditEntryViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var adultTextField: UITextField!
    @IBOutlet weak var kidTextField: UITextField!
    @IBOutlet weak var quotedTimeTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var seatedAtTextField: UITextField!
    @IBOutlet weak var seatedAtLabel: UILabel!
    
    @IBOutlet weak var adultStepper: UIStepper!
    @IBOutlet weak var kidStepper: UIStepper!
    @IBOutlet weak var quotedTimeStepper: UIStepper!
    
    @IBOutlet weak var checkInTimePicker: UIDatePicker!
    @IBOutlet weak var seatingPreferenceControl: UISegmentedControl!
    @IBOutlet weak var partyTypeControl: UISegmentedControl!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    var guest: WaitlistEntry!
    var guestIndex: Int!
    var dataErrors: [String]!
    var estimatedWaitTime: Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10
        removeButton.layer.cornerRadius = 10
        messageButton.layer.cornerRadius = 10
                
        nameTextField.text = guest.name
        adultTextField.text = "\(guest.adults)"
        kidTextField.text = "\(guest.kids)"
        quotedTimeTextField.text = guest.getQuotedTime()
        notesTextField.text = guest.notes
        seatedAtTextField.enabled = false
        
        adultStepper.value = Double(guest.adults)
        kidStepper.value = Double(guest.kids)
        quotedTimeStepper.value = Double(guest.quotedTime)
        
        checkInTimePicker.date = guest.checkInTime
        
        switch guest.seatingPreference {
        case "First Available":
            seatingPreferenceControl.selectedSegmentIndex = 0
        case "Inside":
            seatingPreferenceControl.selectedSegmentIndex = 1
        default:
            seatingPreferenceControl.selectedSegmentIndex = 2
        }
        
        if guest.isCallIn == true {
            partyTypeControl.selectedSegmentIndex = 1
        } else if guest.isReservation == true {
            partyTypeControl.selectedSegmentIndex = 2
        } else {
            partyTypeControl.selectedSegmentIndex = 0
        }
        
        dataErrors = []
        
        if guest.isSeated == true || guest.isRemoved == true {
            nameTextField.enabled = false
            notesTextField.enabled = false
            adultStepper.enabled = false
            kidStepper.enabled = false
            quotedTimeStepper.enabled = false
            checkInTimePicker.enabled = false
            seatingPreferenceControl.enabled = false
            partyTypeControl.enabled = false
            removeButton.hidden = true
        }
        
        if guest.seatedAtTime == nil {
            seatedAtLabel.hidden = true
            seatedAtTextField.hidden = true
        } else {
            seatedAtTextField.text = guest.getSeatedTime()
        }
        
        if guest.phoneNumber == nil && guest.emailAddress == nil {
            messageButton.hidden = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nameValueChanged(text: UITextField) {
        guest.name = text.text
    }
    
    @IBAction func notesValueChanged(text: UITextField) {
        guest.notes = text.text
    }
    
    @IBAction func adultValueChanged(stepper: UIStepper) {
        var value = stepper.value
        guest.adults = Int(value)
        guest.totalGuests = guest.adults.integerValue + guest.kids.integerValue
        adultTextField.text = "\(guest.adults.integerValue)"
    }
    
    @IBAction func kidValueChanged(stepper: UIStepper) {
        var value = stepper.value
        guest.kids = Int(value)
        guest.totalGuests = guest.adults.integerValue + guest.kids.integerValue
        kidTextField.text = "\(guest.kids.integerValue)"
    }
    
    @IBAction func seatingPreferenceChanges(preference: UISegmentedControl) {
        var value = preference.selectedSegmentIndex
        
        switch value {
        case 0:
            guest.seatingPreference = "First Available"
        case 1:
            guest.seatingPreference = "Inside"
        default:
            guest.seatingPreference = "Outside"
        }
        
    }
    
    @IBAction func quotedTimeValueChanged(stepper: UIStepper) {
        var value = stepper.value
        guest.quotedTime = Int(value)
        quotedTimeTextField.text = guest.getQuotedTime()
    }
    
    @IBAction func checkInTimeValueChanged(picker: UIDatePicker) {
        var date = picker.date
        guest.checkInTime = date
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "saveWaitlistEntry" {
            var proceed = validateData()
            var errorString = ""
            if proceed {
                self.guest.name = nameTextField.text
                self.guest.adults = Int(adultStepper.value)
                self.guest.kids = Int(kidStepper.value)
                self.guest.checkInTime = checkInTimePicker.date
                self.guest.quotedTime = Int(quotedTimeStepper.value)
                self.guest.seatingPreference = getSeatingPreference()
                self.guest.notes = notesTextField.text
                self.guest.isReservation = getReservation()
                self.guest.isCallIn = getCallIn()
                if self.guest.isCallIn == true {
                    self.guest.isCheckedIn = false
                } else {
                    self.guest.isCheckedIn = true
                }
                            
                let destinationController = segue.destinationViewController as! WaitlistViewController
                destinationController.waitlist.estimatedTime = Int(estimatedWaitTime)
            } else {
                //Errors validating data, display alert for user with messages
                for item in dataErrors {
                    errorString += item + "\n"
                }
                
                let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                dataErrors = []
            }
        }
        
        if segue.identifier == "deleteWaitlistEntry" {
            let destinationController = segue.destinationViewController as! WaitlistViewController
            destinationController.waitlist.estimatedTime = Int(estimatedWaitTime)
        }
    }

    
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func removeButtonPushed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Remove Entry?", message: "Are you sure you want to remove this entry?", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: deleteEntry)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func messageButtonPushed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Message Guest", message: "How would you like to message this party?", preferredStyle: .Alert)
        
        let textAction = UIAlertAction(title: "Send Text", style: .Default, handler: nil)
        let emailAction = UIAlertAction(title: "Email", style: .Default, handler: sendEmail)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
//        if let number = guest.phoneNumber {
//            alertController.addAction(textAction)
//        }
        
        if let email = guest.emailAddress {
            alertController.addAction(emailAction)
        }
        
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func sendEmail(alert: UIAlertAction!) {
        //let address = [guest.emailAddress!]
        
        let emailController = MFMailComposeViewController()
        emailController.mailComposeDelegate = self
        emailController.setSubject("Your Table is Ready!")
        emailController.setMessageBody("Your table at Claire's on Cedros is ready!", isHTML: false)
        emailController.setToRecipients(["\(guest.emailAddress!)"])
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(emailController, animated: true, completion: nil)
        } else {
            println("Cannot send mail")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendTextMessage() {
        
    }
    
    func deleteEntry(alert: UIAlertAction!) {
        guest.remove()
        performSegueWithIdentifier("deleteWaitlistEntry", sender: nil)
    }
    
    func validateData() -> Bool {
        var dataValid = true
        
        if nameTextField.text == "" {
            dataValid = false
            dataErrors.append("Entry Must Have a Name!")
        }
        
        if adultStepper.value + kidStepper.value == 0 {
            dataValid = false
            dataErrors.append("Entry Must Have At Least 1 Party Member!")
        }
        
        if quotedTimeStepper.value == 0 && partyTypeControl.selectedSegmentIndex != 2 {
            dataValid = false
            dataErrors.append("Quoted Wait Time Required!")
        }
        
        return dataValid
    }
    
    func getSeatingPreference() -> String {
        var preference = ""
        switch seatingPreferenceControl.selectedSegmentIndex {
        case 0:
            preference = "First Available"
        case 1:
            preference = "Inside"
        default:
            preference = "Outside"
        }
        return preference
    }
    
    func getCallIn() -> Bool {
        var isCallIn: Bool
        switch partyTypeControl.selectedSegmentIndex {
        case 1:
            isCallIn = true
        default:
            isCallIn = false
        }
        return isCallIn
    }
    
    func getReservation() -> Bool {
        var isReservation: Bool
        switch partyTypeControl.selectedSegmentIndex {
        case 2:
            isReservation = true
        default:
            isReservation = false
        }
        return isReservation
    }
    
    func getCheckedIn() -> Bool {
        return !self.guest.isCheckedIn.boolValue
    }
}
