//
//  eventDetailTableViewCell.swift
//  Organ.AI
//
//  Created by Ben on 2020/3/9.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import UIKit

class eventDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var eventNote: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
