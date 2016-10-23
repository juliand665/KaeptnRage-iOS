//
//  Snippet.swift
//  KaeptnRage
//
//  Created by Julian Dunskus on 18.10.16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation
import AVFoundation

typealias JSONObject = [String: Any]

class Snippet: NSObject, NSCoding {
	
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		return formatter
	}()
	
	var fileName: String
	var lastChange: Date
	var soundPlayer: AVAudioPlayer?
	var soundData: Data? {
		didSet {
			if let data = soundData {
				soundPlayer = try? AVAudioPlayer(data: data)
			}
		}
	}
	var name: String {
		return fileName.components(separatedBy: " - ").last ?? "unnamed"
	}
	var author: String {
		return fileName.components(separatedBy: " - ").first ?? "unknown"
	}
	
	init(named name: String, changed change: String, data: Data?) {
		fileName = name
		lastChange = Snippet.dateFormatter.date(from: change) ?? Date()
		soundData = data
	}
	
	init?(from json: JSONObject) {
		if let name = json["FileName"] as? String,
		   let change = json["ChangeDate"] as? String {
			fileName = name
			lastChange = Snippet.dateFormatter.date(from: change) ?? Date()
			super.init()
		} else {
			return nil
		}
	}
	
	required init?(coder: NSCoder) {
		if let name = coder.decodeObject(forKey: "fileName") as? String,
		   let change = coder.decodeObject(forKey: "lastChange") as? Date {
			fileName = name
			lastChange = change
			super.init()
			;{ soundData = coder.decodeObject(forKey: "soundData") as? Data }() // to call didSet
		} else {
			return nil
		}
	}
	
	func encode(with coder: NSCoder) {
		coder.encode(fileName, forKey: "fileName")
		coder.encode(lastChange, forKey: "lastChange")
		coder.encode(soundData, forKey: "soundData")
	}
}

extension Snippet { // Equatable
	
	static func ==(lhs: Snippet, rhs: Snippet) -> Bool {
		return lhs.name == rhs.name && lhs.lastChange == rhs.lastChange
	}
}

extension Snippet { // CustomStringConvertible
	
	override var description: String {
		let dataMessage = soundData == nil ? "no" : "some"
		return "Snippet named \(fileName) with \(dataMessage) sound data; last changed on \(lastChange.description)"
	}
}
