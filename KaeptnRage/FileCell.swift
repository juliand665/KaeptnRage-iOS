//
//  FileCell.swift
//  KaeptnRage
//
//  Created by Julian Dunskus on 18.10.16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import UIKit
import AVFoundation

class FileCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var rightLabel: UILabel!
	@IBOutlet weak var filler: UIView!
	@IBOutlet weak var fillerWidth: NSLayoutConstraint!
	
	var snippet: Snippet! {
		didSet {
			nameLabel.text = snippet.name
			let dur = Int(snippet.soundPlayer?.duration ?? 0)
			rightLabel.text = String(format: "%d:%02d", dur / 60, dur % 60)
		}
	}
	
	func play() {
		stop()
		// play
		if let player = snippet.soundPlayer {
			fillerWidth.constant = contentView.frame.width
			UIView.animate(withDuration: player.duration, delay: 0, options: .curveLinear, animations: {
				self.contentView.layoutIfNeeded()
			}) { (_) in
				self.fillerWidth.constant = 0
				self.contentView.layoutIfNeeded()
			}
			
			player.play()
		}
	}
	
	func stop() {
		filler.layer.removeAllAnimations()
		fillerWidth.constant = 0
		contentView.layoutIfNeeded()
		
		snippet.soundPlayer?.currentTime = 0
		snippet.soundPlayer?.pause()
	}
}
