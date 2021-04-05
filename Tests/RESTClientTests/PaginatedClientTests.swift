//
//  PaginatedClientTests.swift
//  Created by Emilio Peláez on 5/4/21.
//

import XCTest
import Combine
@testable import RESTClient

class PaginatedClientTests: XCTestCase {
	
	let client = PaginatedClient<Page>(baseUrl: URL(string: "http://localhost:8080")!)
	var bag: Set<AnyCancellable> = []
	
	func testFirstPage() {
		let expectation = XCTestExpectation(description: "First")
		
		client.page(Object.self, page: 0, pageSize: 5).sink {
			switch $0 {
			case .failure(let error):
				XCTFail("Fetch fail \(error.localizedDescription)")
			case _: break
			}
		} receiveValue: { response in
			let page = Page(page: 0, size: 5, total: 8)
			XCTAssertEqual(response.results, (1...5).map { Object(id: $0, value: "Hello") })
			XCTAssertEqual(response.page, page)
			expectation.fulfill()
		}.store(in: &bag)
		wait(for: [expectation], timeout: 10.0)
	}
	
	func testSecondPage() {
		let expectation = XCTestExpectation(description: "Second")
		
		client.page(Object.self, page: 1, pageSize: 5).sink {
			switch $0 {
			case .failure(let error):
				XCTFail("Fetch fail \(error.localizedDescription)")
			case _: break
			}
		} receiveValue: { response in
			let page = Page(page: 1, size: 3, total: 8)
			XCTAssertEqual(response.results, (6...8).map { Object(id: $0, value: "Hello") })
			XCTAssertEqual(response.page, page)
			expectation.fulfill()
		}.store(in: &bag)
		wait(for: [expectation], timeout: 10.0)
	}
}
