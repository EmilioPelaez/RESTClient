//
//  HTTPClientTests.swift
//  RESTClientTests
//
//  Created by Emilio Peláez on 21/11/20.
//

import XCTest
import Combine
@testable import RESTClient

class HTTPClientTests: XCTestCase {
	
	let client = HTTPClient()
	var bag: Set<AnyCancellable> = []
	
	func testSuccess() {
		let expectation = XCTestExpectation(description: "Success")
		
		client.performRequest(for: URL(string: "http://localhost:8080")!).sink {
			switch $0 {
			case .failure(let error):
				XCTFail("Fetch fail \(error.localizedDescription)")
			case _: break
			}
		} receiveValue: { _ in
			expectation.fulfill()
		}.store(in: &bag)
		wait(for: [expectation], timeout: 10.0)
	}
	
	@available(iOS 15.0, *)
	func testAsyncSuccess() {
		let expectation = XCTestExpectation(description: "Success")
		
		async {
			do {
				let _ = try await client.performRequest(for: URL(string: "http://localhost:8080")!)
				expectation.fulfill()
			} catch {
				XCTFail("Fetch fail \(error.localizedDescription)")
			}
		}
		wait(for: [expectation], timeout: 10.0)
	}
	
	func testFailure() {
		let expectation = XCTestExpectation(description: "Failure")
		
		client.performRequest(for: URL(string: "http://localhost:8080")!, method: .POST).sink {
			switch $0 {
			case .failure:
				expectation.fulfill()
			case _:
				XCTFail("Fetch fail failed")
			}
		} receiveValue: { _ in
		}.store(in: &bag)
		wait(for: [expectation], timeout: 10.0)
	}
	
	@available(iOS 15.0, *)
	func testAsyncFailure() {
		let expectation = XCTestExpectation(description: "Failure")
		
		async {
			do {
				let _ = try await client.performRequest(for: URL(string: "http://localhost:8080")!, method: .POST)
				XCTFail("Fetch fail. Expected failure")
			} catch {
				expectation.fulfill()
			}
		}
		wait(for: [expectation], timeout: 10.0)
	}
	
}
