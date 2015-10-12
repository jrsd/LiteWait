//
//  WaitListTableViewCell.swift
//  LiteWait
//
//  Created by mhat on 7/22/15.
//  Copyright (c) 2015 mhat. All rights reserved.
//

import UIKit

class WaitListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var totalGuestLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var guestNumberLabel: UILabel!
    @IBOutlet weak var checkInTimeLabel: UILabel!
    @IBOutlet weak var quotedWaitTimeLabel: UILabel!
    @IBOutlet weak var seatingPreferenceLabel: UILabel!
    @IBOutlet weak var seatingPreferenceImage: UIImageView!
    @IBOutlet weak var notesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        totalGuestLabel.layer.cornerRadius = 20
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
