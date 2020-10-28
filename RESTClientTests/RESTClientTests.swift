//
//  RESTClientTests.swift
//  RESTClientTests
//
//  Created by Emilio Peláez on 27/10/20.
//

import XCTest
@testable import RESTClient

class RESTClientTests: XCTestCase {
	
	let values = (1...10)
	let client = RESTClient(baseUrl: URL(string: "localhost:8080")!)
	
	func testAll() {
		let expectation = XCTestExpectation(description: "All")
		
		let test = client.all(Object.self).sink {
			switch $0 {
			case .failure(let error):
				XCTFail("Fetch fail \(error.localizedDescription)")
			case _: break
			}
		} receiveValue: { objects in
			XCTAssertEqual(objects, self.values.map { Object(id: $0, value: "Hello") })
			expectation.fulfill()
			self.wait(for: [expectation], timeout: 10.0)
		}
	}
	
}
