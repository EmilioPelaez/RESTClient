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
	
	open func performRequest(_ request: URLRequest, requestConfiguration: (inout URLRequest) -> Void = { _ in }) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
		var request = request
		requestConfiguration(&request)
		return session.dataTaskPublisher(for: request)
			.tryMap(validateResponse)
			.map(transformResponse)
			.eraseToAnyPublisher()
	}
}
