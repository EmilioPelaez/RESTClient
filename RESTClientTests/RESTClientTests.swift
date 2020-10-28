//
//  RESTClientTests.swift
//  RESTClientTests
//
//  Created by Emilio Peláez on 27/10/20.
//

import XCTest
import Combine
@testable import RESTClient

class RESTClientTests: XCTestCase {
	
	let values = (1...10)
	let client = RESTClient(baseUrl: URL(string: "http://localhost:8080")!)
	var bag: Set<AnyCancellable> = []
	
	func testAll() {
		let expectation = XCTestExpectation(description: "All")
		
		client.all(Object.self).sink {
			switch $0 {
			case .failure(let error):
				XCTFail("Fetch fail \(error.localizedDescription)")
			case _: break
			}
		} receiveValue: { objects in
			XCTAssertEqual(objects, self.values.map { Object(id: $0, value: "Hello") })
			expectation.fulfill()
		}.store(in: &bag)
		wait(for: [expectation], timeout: 10.0)
	}
	
	func testFirst() {
		let expectation = XCTestExpectation(description: "First")
		
		client.first(Object.self).sink {
			switch $0 {
			case .failure(let error):
				XCTFail("Fetch fail \(error.localizedDescription)")
			case _: break
			}
		} receiveValue: { object in
			XCTAssertEqual(object, Object(id: 1, value: "Hello"))
			expectation.fulfill()
		}.store(in: &bag)
		wait(for: [expectation], timeout: 10.0)
	}
	
	func testFind() {
		let expectation = XCTestExpectation(description: "Find")
		
		client.find(Object.self, identifier: 1).sink {
			switch $0 {
			case .failure(let error):
				XCTFail("Fetch fail \(error.localizedDescription)")
			case _: break
			}
		} receiveValue: { object in
			XCTAssertEqual(object, Object(id: 1, value: "Hello"))
			expectation.fulfill()
		}.store(in: &bag)
		wait(for: [expectation], timeout: 10.0)
	}
	
	func testCreate() {
		let expectation = XCTestExpectation(description: "Create")
		
		client.create(NewObject(value: "Hello"), receive: Object.self).sink {
			switch $0 {
			case .failure(let error):
				XCTFail("Fetch fail \(error.localizedDescription)")
			case _: break
			}
		} receiveValue: { object in
			XCTAssertEqual(object, Object(id: 11, value: "Hello"))
			expectation.fulfill()
		}.store(in: &bag)
		wait(for: [expectation], timeout: 10.0)
	}
	
	func testDelete() {
		let expectation = XCTestExpectation(description: "Delete")
		
		client.delete(Object.self, identifier: "1").sink {
			switch $0 {
			case .failure(let error):
				XCTFail("Fetch fail \(error.localizedDescription)")
			case _: break
			}
		} receiveValue: {
			expectation.fulfill()
		}.store(in: &bag)
		wait(for: [expectation], timeout: 10.0)
	}
	
}
