//
//  HTTPClient.swift
//  RESTClient
//
//  Created by Emilio Peláez on 12/11/20.
//

import Foundation
import Combine

open class HTTPClient {
	
	public struct HTTPError: Error {
		public let code: Int
	}
	public let session: URLSession
	
	open var requestConfiguration: (inout URLRequest) -> Void = { _ in }
	open var validateResponse: (Data, URLResponse) throws -> (Data, URLResponse)
	open var transformResponse: (Data, URLResponse) -> (Data, URLResponse) = { ($0, $1) }
	
	public init(session: URLSession = .shared) {
		self.session = session
		
		self.validateResponse = { data, response in
			if let response = response as? HTTPURLResponse, !(200..<300).contains(response.statusCode) {
				throw HTTPError(code: response.statusCode)
			}
			return (data, response)
		}
	}
	
	open func performRequest(for url: URL, method: HTTPMethod = .GET, body: @autoclosure () throws -> HTTPBody? = nil, configuration: (inout URLRequest) -> Void = { _ in }) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
		var request = URLRequest(url: url)
		request.httpMethod = method.description
		do {
			if let body = try body() {
				request.httpBody = body.data
				request.addValue(body.contentType.description, forHTTPHeaderField: "Content-Type")
			}
		} catch {
			return Fail(outputType: (data: Data, response: URLResponse).self, failure: error)
				.eraseToAnyPublisher()
		}
		configuration(&request)
		return performRequest(request)
	}
	
	open func performRequest(_ request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
		return session.dataTaskPublisher(for: request)
			.tryMap(validateResponse)
			.map(transformResponse)
			.eraseToAnyPublisher()
	}
}
