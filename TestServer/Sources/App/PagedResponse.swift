//
//  PagedResponse.swift
//  Created by Emilio Peláez on 5/4/21.
//

import Foundation

struct PagedResponse<T: Codable>: Codable {
	let page: Page
	let results: T
}

struct Page: Codable {
	let page: Int
	let size: Int
	let total: Int
}
