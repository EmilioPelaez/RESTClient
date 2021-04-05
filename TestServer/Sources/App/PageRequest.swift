//
//  PageRequest.swift
//  Created by Emilio Peláez on 5/4/21.
//

import Foundation

struct PageRequest: Decodable {
	let page: Int
	let pageSize: Int
	var start: Int {
		page * pageSize
	}
}
