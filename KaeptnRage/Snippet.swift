//
//  Snippet.swift
//  KaeptnRage
//
//  Created by Julian Dunskus on 18.10.16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation
import Mantle

typealias JSONObject = [String: Any]

class Snippet: MTLModel, MTLJSONSerializing {
	
	var fileName: String!
	var lastChange: Date!
	
	var name: String {
		get {
			return fileName.components(separatedBy: " - ").last!
		}
	}
	
	static let dateFormatter = { () -> DateFormatter in 
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		return formatter
	}()
	
	static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
		return [
			"fileName": "FileName",
			"lastChange": "ChangeDate"
		]
	}
	
	static func jsonTransformer(forKey key: String!) -> ValueTransformer! {
		if key == "lastChange" {
			return MTLValueTransformer(usingReversibleBlock: { (from, success, error) -> Any? in
				if let date = from as? Date {
					return dateFormatter.string(from: date)
				}
				if let string = from as? String {
					return dateFormatter.date(from: string)
				}
				return nil
			})
		}
		return nil
	}
}
