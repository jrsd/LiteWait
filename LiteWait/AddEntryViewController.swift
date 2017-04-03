//
//  AddEntryViewController.swift
//  LiteWait
//
//  Created by mhat on 7/23/15.
//  Copyright (c) 2015 mhat. All rights reserved.
//

import UIKit
import CoreData

class AddEntryViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var adultTextField: UITextField!
    @IBOutlet weak var kidTextField: UITextField!
    @IBOutlet weak var quotedTimeTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    @IBOutlet weak var adultStepper: UIStepper!
    @IBOutlet weak var kidStepper: UIStepper!
    @IBOutlet weak var quotedTimeStepper: UIStepper!
    
    @IBOutlet weak var checkInTimePicker: UIDatePicker!
    @IBOutlet weak var seatingPreferenceControl:UISegmentedControl!
    @IBOutlet weak var partyTypeControl: UISegmentedControl!
        
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
        
    var dataErrors: [String]!
    
    var entry: WaitlistEntry!
    var estimatedWaitTime: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adultTextField.text = "0"
        kidTextField.text = "0"
        quotedTimeTextField.text = "0"
        
        adultStepper.value = 0
        kidStepper.value = 0
        quotedTimeStepper.value = 0
        seatingPreferenceControl.selectedSegmentIndex = 0
        
        phoneNumberTextField.isEnabled = false
        
        if estimatedWaitTime != nil{
            quotedTimeStepper.value = estimatedWaitTime
            quotedTimeTextField.text = getQuotedTime(estimatedWaitTime)
        }
        
        cancelButton.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10
        
        dataErrors = []
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func adultValueChanged(_ stepper: UIStepper) {
        adultTextField.text = "\(Int(stepper.value))"
    }
    
    @IBAction func kidValueChanged(_ stepper: UIStepper) {
        kidTextField.text = "\(Int(stepper.value))"
    }
    
    @IBAction func quotedTimeValueChanged(_ stepper: UIStepper) {
        quotedTimeTextField.text = getQuotedTime(stepper.value)
    }
    
    func getQuotedTime(_ value: Double) -> String {
        var timeString = ""
        let number = Int(value)
        
        if number < 60 {
            timeString = "\(number) Minutes"
        } else if number == 60 {
            timeString = "1 Hour"
        } else {
            timeString = "1 Hour \(number - 60) minutes"
        }
        
        return timeString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "saveWaitlistEntry" {
            let proceed = validateData()
            var errorString = ""
            
            //data is valid, create WaitlistEntry based on current values
            if proceed {
                
                if let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext {
                    
                    entry = NSEntityDescription.insertNewObject(forEntityName: "WaitlistEntry",
                    into: managedObjectContext) as! WaitlistEntry
                    entry.name = nameTextField.text!
                    entry.adults = NSNumber(value: adultStepper.value)
                    entry.kids = NSNumber(value: kidStepper.value)
                    let totalGuests = adultStepper.value + kidStepper.value
                    entry.totalGuests = NSNumber(value: totalGuests)
                    entry.checkInTime = checkInTimePicker.date
                    entry.quotedTime = NSNumber(value: quotedTimeStepper.value)
                    entry.seatingPreference = getSeatingPreference()
                    entry.notes = notesTextField.text!
                    entry.isReservation = getReservation() as NSNumber
                    entry.isCallIn = getCallIn().0 as NSNumber
                    entry.isCheckedIn = getCallIn().1 as NSNumber
                    entry.isSeated = false
                    entry.isRemoved = false
                    
                    if phoneNumberTextField.text != "" {
                        entry.phoneNumber = phoneNumberTextField.text
                    }
                    
                    if emailAddressTextField.text != "" {
                        entry.emailAddress = emailAddressTextField.text
                    }
                    
                    do {
                        try managedObjectContext.save()
                    } catch {
                        print("Error")
                    }
                }
                
                let destinationController = segue.destination as! WaitlistViewController
                destinationController.waitlist.estimatedTime = Int(estimatedWaitTime)
                
            } else {
                //Errors validating data, display alert for user with messages
                for item in dataErrors {
                    errorString += item + "\n"
                }
                
                let alertController = UIAlertController(title: "Oops!", message: errorString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                dataErrors = []
            }
        }
    }
    
    func validateData() -> Bool {
        var dataValid = true
        
        if nameTextField.text == "" {
            dataValid = false
            dataErrors.append("\nA Name is Required")
        }
        
        if adultStepper.value + kidStepper.value == 0 {
            dataValid = false
            dataErrors.append("\nParty Must Have At Least 1 Member")
        }
        
        if quotedTimeStepper.value == 0 && partyTypeControl.selectedSegmentIndex != 2{
            dataValid = false
            dataErrors.append("\nA Quoted Wait Time Required")
        }
        
        if emailAddressTextField.text != "" {
            if validateEmail() == false {
                dataValid = false
                dataErrors.append("\nEmail address is invalid")
            }
            
        }
        
        if phoneNumberTextField.text != "" {
            if validatePhoneNumber() == false {
                dataValid = false
                dataErrors.append("\nPhone number is invalid")
            }
            
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
    
    func getCallIn() -> (Bool, Bool) {
        var isCallIn: Bool
        var isCheckedIn: Bool
        switch partyTypeControl.selectedSegmentIndex {
        case 1:
            isCallIn = true
            isCheckedIn = false
        default:
            isCallIn = false
            isCheckedIn = true
        }
        
        return (isCallIn, isCheckedIn)
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
        
    @IBAction func cancelButtonPushed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func validateEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let isValid = emailTest.evaluate(with: emailAddressTextField.text)
        
        return isValid
    }
    
    func validatePhoneNumber() -> Bool {
        let phoneRegEx = "^\\d{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        
        let isValid =  phoneTest.evaluate(with: phoneNumberTextField.text)
        
        return isValid
    }
    
}
