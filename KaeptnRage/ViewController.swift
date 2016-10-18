//
//  ViewController.swift
//  KaeptnRage
//
//  Created by Julian Dunskus on 18.10.16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import UIKit
import Mantle

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
	
	@IBAction func refresh(_ refresher: UIRefreshControl) {
		updater.requestNewSnippets { (new) in
			self.snippets = new ?? []
			self.save()
			self.tableView.reloadData()
			refresher.endRefreshing()
			print("Refresh ended!", new)
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
