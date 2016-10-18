//
//  Updater.swift
//  KaeptnRage
//
//  Created by Julian Dunskus on 18.10.16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Mantle

class Updater {
	
	let baseURL = URL(string: "https://api.kaeptnrage.famoser.ch")!
	
	func requestNewSnippets(_ completion: @escaping ([Snippet]?) -> Void) {
		
		let url = URL(string: "index.php", relativeTo: baseURL)!
		
		let session = URLSession(configuration: .default)
		let task = session.dataTask(with: url) { (data, response, error) in
			if let data = data,
				let json = try? JSONSerialization.jsonObject(with: data) as? JSONObject,
				let array = json?["Files"] as? [JSONObject] {
				
				do {
					let snippets = try MTLJSONAdapter.models(of: Snippet.self, fromJSONArray: array).map { $0 as! Snippet }
					completion(snippets)
					return
				} catch {
					print(error)
				}
			}
			print("something failed")
			print(data)
			print(response)
			print(error)
			completion(nil)
		}
		task.resume()
	}
}
