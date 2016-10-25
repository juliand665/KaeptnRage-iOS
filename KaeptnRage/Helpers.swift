//
//  Helpers.swift
//  KaeptnRage
//
//  Created by Julian Dunskus on 24.10.16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation

/// Access nested `Collection` elements by `IndexPath`
extension Collection where Index == Int, Iterator.Element: Collection, Iterator.Element.Index == Int {
	
	subscript(indexPath: IndexPath) -> Iterator.Element.Iterator.Element {
		return self[indexPath[0]][indexPath[1]]
	}
}
