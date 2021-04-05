//
//  File.swift
//  
//
//  Created by Emilio Peláez on 5/4/21.
//

import Foundation

struct Page {
	let page: Int
	let size: Int
	let total: Int
}

extension Page: Codable {}

extension Page: Equatable {}
