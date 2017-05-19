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
    
    var waitlistState: WaitlistModes!
    
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
        seatedAtTextField.isEnabled = false
        
        adultStepper.value = Double(guest.adults)
        kidStepper.value = Double(guest.kids)
        quotedTimeStepper.value = Double(guest.quotedTime)
        
        checkInTimePicker.date = guest.checkInTime as Date
        
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
            nameTextField.isEnabled = false
            notesTextField.isEnabled = false
            adultStepper.isEnabled = false
            kidStepper.isEnabled = false
            quotedTimeStepper.isEnabled = false
            checkInTimePicker.isEnabled = false
            seatingPreferenceControl.isEnabled = false
            partyTypeControl.isEnabled = false
            removeButton.isHidden = true
        }
        
        if guest.seatedAtTime == nil {
            seatedAtLabel.isHidden = true
            seatedAtTextField.isHidden = true
        } else {
            seatedAtTextField.text = guest.getSeatedTime()
        }
        
        if guest.phoneNumber == nil && guest.emailAddress == nil {
            messageButton.isHidden = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nameValueChanged(_ text: UITextField) {
        guest.name = text.text!
    }
    
    @IBAction func notesValueChanged(_ text: UITextField) {
        guest.notes = text.text!
    }
    
    @IBAction func adultValueChanged(_ stepper: UIStepper) {
        let num = stepper.value
        guest.adults = NSNumber(value: num)
        let totalGuests = guest.adults.intValue + guest.kids.intValue
        guest.totalGuests = NSNumber(value: totalGuests)
        adultTextField.text = "\(guest.adults.intValue)"
    }
    
    @IBAction func kidValueChanged(_ stepper: UIStepper) {
        let num = stepper.value
        guest.kids = NSNumber(value: num)
        let totalGuests = guest.adults.intValue + guest.kids.intValue
        guest.totalGuests = NSNumber(value: totalGuests)
        kidTextField.text = "\(guest.kids.intValue)"
    }
    
    @IBAction func seatingPreferenceChanges(_ preference: UISegmentedControl) {
        let value = preference.selectedSegmentIndex
        
        switch value {
        case 0:
            guest.seatingPreference = "First Available"
        case 1:
            guest.seatingPreference = "Inside"
        default:
            guest.seatingPreference = "Outside"
        }
        
    }
    
    @IBAction func quotedTimeValueChanged(_ stepper: UIStepper) {
        let value = stepper.value
        guest.quotedTime = NSNumber(value: value)
        quotedTimeTextField.text = guest.getQuotedTime()
    }
    
    @IBAction func checkInTimeValueChanged(_ picker: UIDatePicker) {
        let date = picker.date
        guest.checkInTime = date
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "saveWaitlistEntry" {
            let proceed = validateData()
            var errorString = ""
            let adults = adultStepper.value
            let kids = kidStepper.value
            let quotedTime = quotedTimeStepper.value
            if proceed {
                self.guest.name = nameTextField.text!
                self.guest.adults = NSNumber(value: adults)
                self.guest.kids = NSNumber(value: kids)
                self.guest.checkInTime = checkInTimePicker.date
                self.guest.quotedTime = NSNumber(value: quotedTime)
                self.guest.seatingPreference = getSeatingPreference()
                self.guest.notes = notesTextField.text!
                self.guest.isReservation = getReservation() as NSNumber
                self.guest.isCallIn = getCallIn() as NSNumber
                self.guest.isCheckedIn = getCheckedIn() as NSNumber
                
                
                    
                let destinationController = segue.destination as! WaitlistViewController
                destinationController.waitlist.estimatedTime = Int(estimatedWaitTime)
                destinationController.waitlist.setMode(waitlistState)
            } else {
                //Errors validating data, display alert for user with messages
                for item in dataErrors {
                    errorString += item + "\n"
                }
                
                let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                dataErrors = []
            }
        }
        
        if segue.identifier == "deleteWaitlistEntry" {
            let destinationController = segue.destination as! WaitlistViewController
            destinationController.waitlist.estimatedTime = Int(estimatedWaitTime)
        }
    }

    
    @IBAction func cancelButtonPushed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeButtonPushed(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Remove Entry?", message: "Are you sure you want to remove this entry?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: deleteEntry)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

//    @IBAction func messageButtonPushed(sender: AnyObject) {
//        let alertController = UIAlertController(title: "Message Guest", message: "How would you like to message this party?", preferredStyle: .Alert)
        
//        let textAction = UIAlertAction(title: "Send Text", style: .Default, handler: nil)
//        let emailAction = UIAlertAction(title: "Email", style: .Default, handler: sendEmail)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
//
//        if let number = guest.phoneNumber {
//            alertController.addAction(textAction)
//        }
        
//        if let email = guest.emailAddress {
//            alertController.addAction(emailAction)
//        }
//        
//        alertController.addAction(cancelAction)
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
//
//    func sendEmail(alert: UIAlertAction!) {
//        //let address = [guest.emailAddress!]
//        
//        let emailController = MFMailComposeViewController()
//        emailController.mailComposeDelegate = self
//        emailController.setSubject("Your Table is Ready!")
//        emailController.setMessageBody("Your table at Claire's on Cedros is ready!", isHTML: false)
//        emailController.setToRecipients(["\(guest.emailAddress!)"])
//        
//        if MFMailComposeViewController.canSendMail() {
//            self.presentViewController(emailController, animated: true, completion: nil)
//        } else {
//            print("Cannot send mail")
//        }
//    }
//    
//    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
//        controller.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func sendTextMessage() {
//        
//    }
    
    func deleteEntry(_ alert: UIAlertAction!) {
        guest.remove()
        performSegue(withIdentifier: "deleteWaitlistEntry", sender: nil)
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
        if self.guest.isCallIn == true && self.guest.isCheckedIn == false {
            return false
        } else {
            return true
        }
    }
}
