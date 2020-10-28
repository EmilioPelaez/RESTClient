//
//  RESTClient.swift
//  RESTClient
//
//  Created by Emilio Peláez on 27/10/20.
//

import Foundation
import Combine

class RESTClient: TopLevelDecoder {
	
	let baseUrl: URL
	let session: URLSession
	let encoder: JSONEncoder
	let decoder: JSONDecoder
	
	var requestConfiguration: (inout URLRequest) -> Void = { _ in }
	
	init(baseUrl: URL, session: URLSession = .shared, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
		self.baseUrl = baseUrl
		self.session = session
		self.encoder = encoder
		self.decoder = decoder
	}
	
	func all<T: RemoteResource>(_ type: T.Type, pathPrefix: String? = nil) -> AnyPublisher<[T], Error> {
		let url = buildUrl(for: T.self, prefix: pathPrefix)
		let request = URLRequest(url: url)
		return performRequest(request, requestConfiguration: requestConfiguration)
			.map(\.data)
			.decode(type: [T].self, decoder: self)
			.eraseToAnyPublisher()
	}
	
	func first<T: RemoteResource>(_ type: T.Type, pathPrefix: String? = nil) -> AnyPublisher<T?, Error> {
		let url = buildUrl(for: T.self, prefix: pathPrefix)
		let request = URLRequest(url: url)
		return performRequest(request, requestConfiguration: requestConfiguration)
			.map(\.data)
			.decode(type: [T].self, decoder: self)
			.map(\.first)
			.eraseToAnyPublisher()
	}
	
	func find<T: UniqueRemoteResource>(_ type: T.Type, identifier: T.ID, pathPrefix: String? = nil) -> AnyPublisher<T, Error> {
		let url = buildUrl(for: T.self, prefix: pathPrefix).appendingPathComponent(String(describing: identifier))
		let request = URLRequest(url: url)
		return performRequest(request, requestConfiguration: requestConfiguration)
			.map(\.data)
			.decode(type: T.self, decoder: self)
			.eraseToAnyPublisher()
	}
	
	func create<T: Encodable, U: RemoteResource>(_ body: T, pathPrefix: String? = nil) -> AnyPublisher<U, Error> {
		let url = buildUrl(for: U.self, prefix: pathPrefix)
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		do {
			request.httpBody = try encoder.encode(body)
			return performRequest(request, requestConfiguration: requestConfiguration)
				.map(\.data)
				.decode(type: U.self, decoder: self)
				.eraseToAnyPublisher()
		} catch {
			return Fail(outputType: U.self, failure: error).eraseToAnyPublisher()
		}
	}
	
	func update<T: UniqueRemoteResource>(_ resource: T, pathPrefix: String? = nil) -> AnyPublisher<T, Error> {
		let url = buildIdentifierdUrl(for: resource, prefix: pathPrefix)
		var request = URLRequest(url: url)
		request.httpMethod = "PUT"
		do {
			request.httpBody = try encoder.encode(resource)
			return performRequest(request, requestConfiguration: requestConfiguration)
				.map(\.data)
				.decode(type: T.self, decoder: self)
				.eraseToAnyPublisher()
		} catch {
			return Fail(outputType: T.self, failure: error).eraseToAnyPublisher()
		}
	}
	
	func delete<T: UniqueRemoteResource>(_ resource: T, pathPrefix: String? = nil) -> AnyPublisher<Void, Error> {
		delete(type(of: resource), identifier: String(describing: resource.id), pathPrefix: pathPrefix)
	}
	
	func delete<T: RemoteResource>(_ type: T.Type, identifier: String, pathPrefix: String? = nil) -> AnyPublisher<(), Error> {
		let url = buildUrl(for: type, prefix: pathPrefix)
		var request = URLRequest(url: url)
		request.httpMethod = "DELETE"
		return performRequest(request, requestConfiguration: requestConfiguration)
			.map { _ in  }
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func performRequest(_ request: URLRequest, requestConfiguration: (inout URLRequest) -> Void = { _ in }) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
		var request = request
		requestConfiguration(&request)
		return session.dataTaskPublisher(for: request)
			.eraseToAnyPublisher()
	}
	
	func buildIdentifierdUrl<T: UniqueRemoteResource>(for resource: T, prefix: String?) -> URL {
		buildUrl(for: resource, prefix: prefix).appendingPathComponent(String(describing: resource.id))
	}
	
	func buildUrl<T: RemoteResource>(for resource: T, prefix: String?) -> URL {
		buildUrl(for: type(of: resource), prefix: prefix)
	}
	
	func buildUrl<T: RemoteResource>(for resourceType: T.Type, prefix: String?) -> URL {
		if let prefix = prefix {
			return baseUrl.appendingPathComponent(prefix).appendingPathComponent(T.path)
		} else {
			return baseUrl.appendingPathComponent(T.path)
		}
	}
	
	func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
		try decoder.decode(type, from: data)
	}
	
}
