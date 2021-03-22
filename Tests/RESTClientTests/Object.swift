//
//  Object.swift
//  RESTClientTests
//
//  Created by Emilio Peláez on 28/10/20.
//

import Foundation
@testable import RESTClient

struct Object: UniqueRemoteResource {
	let id: Int
	let value: String
}

extension Object: Equatable {
	static func ==(lhs: Object, rhs: Object) -> Bool {
		lhs.id == rhs.id && lhs.value == rhs.value
	}
}
