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
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
			self.tableView.reloadData()
			refresher.endRefreshing() // TODO does this need to be done on the main queue?
			print("Refresh ended!", new)
		}
	}
}
