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
	
	var snippets: [Snippet] = [] {
		didSet {
			snippetsByAuthor = []
			var list: [Snippet] = []
			for snippet in snippets {
				if list.isEmpty || snippet.author == list.first!.author {
					list.append(snippet)
				} else {
					snippetsByAuthor.append(list)
					list = [snippet]
				}
			}
			snippetsByAuthor.append(list)
		}
	}
	
	fileprivate var snippetsByAuthor: [[Snippet]]! {
		didSet {
			cells = snippetsByAuthor.map {
				$0.map { snippet -> FileCell in
					let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell") as! FileCell
					cell.snippet = snippet
					return cell
				}
			}
		}
	}
	
	fileprivate var cells: [[FileCell]]!
	let updater = Updater()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNeedsStatusBarAppearanceUpdate()
		load()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
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
	
	@IBAction func stopPressed(_ sender: UIBarButtonItem) {
		for snippet in snippets {
			snippet.soundPlayer?.stop()
			snippet.soundPlayer?.currentTime = 0
		}
		for row in cells {
			for cell in row {
				cell.stop()
			}
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

// MARK: - Table View Delegate
extension ViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return max(1, snippetsByAuthor.count)
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return snippetsByAuthor.isEmpty ? "Pull down to Download" : snippetsByAuthor[section].first?.author
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return snippetsByAuthor.isEmpty ? 0 : snippetsByAuthor[section].count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		return cells[indexPath]
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		defer {
			tableView.deselectRow(at: indexPath, animated: false)
		}
		
		cells[indexPath].play()
	}
}
