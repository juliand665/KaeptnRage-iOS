//
//  ViewController.swift
//  KaeptnRage
//
//  Created by Julian Dunskus on 18.10.16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UITableViewController {
	
	var snippets: [Snippet] = []
	let updater = Updater()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		load()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return snippets.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell") as! FileCell
		
		cell.snippet = snippets[indexPath.row]
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		defer {
			tableView.deselectRow(at: indexPath, animated: true)
		}
		
		let snippet = snippets[indexPath.row]
		
		if let player = snippet.soundPlayer {
			player.currentTime = 0 // for DJing
			player.play()
		} else {
			print("Could not get sound player for", snippet)
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return snippets.isEmpty ? "Pull down to Download" : "Downloaded Snippets"
	}
	
	@IBAction func refresh(_ refresher: UIRefreshControl) {
		updater.requestNewSnippets { (new) in
			if let new = new {
				let group = DispatchGroup()
				
				for snippet in new {
					if let prev = self.snippets.first(where: { $0 == snippet })?.soundData {
						snippet.soundData = prev
					} else {
						group.enter()
						self.updater.requestSound(for: snippet) { 
							group.leave()
						}
					}
				}
				
				self.snippets = new
				self.tableView.reloadData()
				
				group.notify(queue: .main) {
					self.save()
					self.tableView.reloadData()
					refresher.endRefreshing()
				}
			}
		}
	}
	
	func requestSoundData(for snippets: [Snippet], completion: @escaping () -> Void) {
		let group = DispatchGroup()
		for snippet in snippets {
			print("requesting", snippet)
			group.enter()
			updater.requestSound(for: snippet) {
				print("got", snippet)
				group.leave()
			}
		}
		group.notify(queue: .main) { 
			completion()
		}
	}
	
	/// loads data from defaults using NSKeyedUnarchiver
	func load() {
		if let data = UserDefaults.standard.data(forKey: "snippets") {
			NSKeyedUnarchiver.setClass(Snippet.self, forClassName: "Snippet")
			if let obj = NSKeyedUnarchiver.unarchiveObject(with: data) {
				snippets = obj as! [Snippet]
			}
		}
	}
	
	/// saves data to defaults using NSKeyedArchiver
	func save() {
		NSKeyedArchiver.setClassName("Snippet", for: Snippet.self)
		let data = NSKeyedArchiver.archivedData(withRootObject: snippets)
		UserDefaults.standard.set(data, forKey: "snippets")
	}
}
