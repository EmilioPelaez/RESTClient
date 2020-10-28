//
//  NewObject.swift
//  RESTClientTests
//
//  Created by Emilio Peláez on 28/10/20.
//

import Foundation
@testable import RESTClient

struct NewObject: RemoteResource {
	static var path: String { "objects" }
	
	let value: String
}
