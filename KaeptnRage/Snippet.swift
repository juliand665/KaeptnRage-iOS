//
//  Snippet.swift
//  KaeptnRage
//
//  Created by Julian Dunskus on 18.10.16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation
import AVFoundation
import Mantle

typealias JSONObject = [String: Any]

class Snippet: MTLModel, MTLJSONSerializing {
	
	var fileName: String!
	var lastChange: Date!
	var soundPlayer: AVAudioPlayer?
	var soundData: Data? {
		didSet {
			if let data = soundData {
				soundPlayer = try? AVAudioPlayer(data: data)
			}
		}
	}
	
	var name: String {
		get {
			return fileName.components(separatedBy: " - ").last!
		}
	}
	
	static func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {
		return [
			"fileName": "FileName",
			"lastChange": "ChangeDate",
			"soundData": "soundData"
		]
	}
	
	static func jsonTransformer(forKey key: String!) -> ValueTransformer! {
		if key == "lastChange" {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
			
			return MTLValueTransformer(usingReversibleBlock: { (from, success, error) in
				if let date = from as? Date {
					return formatter.string(from: date)
				}
				if let string = from as? String {
					return formatter.date(from: string)
				}
				return nil
			})
		}
		return nil
	}
}

extension Snippet { // CustomStringConvertible
	
	override func description() -> String! {
		let dataMessage = soundData == nil ? "some" : "no"
		return "Snippet named \(fileName) with \(dataMessage) sound data; last changed on \(lastChange.description)"
	}
}
