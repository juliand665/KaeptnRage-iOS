//
//  Updater.swift
//  KaeptnRage
//
//  Created by Julian Dunskus on 18.10.16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation

class Updater {
	
	let baseURL = URL(string: "https://api.kaeptnrage.famoser.ch")!
	let session = URLSession.shared
	
	func requestNewSnippets(completion: @escaping ([Snippet]?) -> Void) {
		
		let url = URL(string: "index.php", relativeTo: baseURL)!
		
		session.dataTask(with: url) { (data, response, error) in
			if let data = data,
			   let json = try? JSONSerialization.jsonObject(with: data) as? JSONObject,
			   let array = json?["Files"] as? [JSONObject] { // nice
				
				let snippets = array.flatMap(Snippet.init)
				completion(snippets)
				return
			}
			print("something failed!")
			print(data?.count)
			print(response)
			print(error)
			completion(nil)
		}.resume()
	}
	
	func requestSound(for snippet: Snippet, completion: @escaping () -> Void) {
		
		if let encoded = snippet.fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
			let url = URL(string: "public/sounds/\(encoded)", relativeTo: baseURL) {
			
			session.dataTask(with: url) { (data, response, error) in
				if let data = data {
					snippet.soundData = data
				} else {
					print("something failed!")
					print(data?.count)
					print(response)
					print(error)
				}
				completion()
			}.resume()
		} else {
			print("Could not create URL for", snippet)
			completion()
		}
	}
}
