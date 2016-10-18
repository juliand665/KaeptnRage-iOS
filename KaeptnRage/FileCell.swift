//
//  FileCell.swift
//  KaeptnRage
//
//  Created by Julian Dunskus on 18.10.16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import UIKit

class FileCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	
	var snippet: Snippet! {
		didSet {
			nameLabel.text = snippet.name
		}
	}
}
