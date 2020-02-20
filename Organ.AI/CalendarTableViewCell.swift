//
//  CalendarTableViewCell.swift
//  Organ.AI
//
//  Created by Ben on 2020/2/20.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {


    @IBOutlet weak var eventDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
