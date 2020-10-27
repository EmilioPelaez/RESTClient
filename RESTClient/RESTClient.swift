//
//  RESTClient.swift
//  RESTClient
//
//  Created by Emilio Peláez on 27/10/20.
//

import Foundation
import Combine

class RESTClient {
	
	let baseUrl: URL
	let session: URLSession
	let encoder: JSONEncoder
	let decoder: JSONDecoder
	
	init(baseUrl: URL, session: URLSession = .shared, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
		self.baseUrl = baseUrl
		self.session = session
		self.encoder = encoder
		self.decoder = decoder
	}
	
	func all<T: RemoteResource>(pathPrefix: String? = nil) -> AnyPublisher<[T], Error> {
		let url = buildUrl(for: T.self, prefix: pathPrefix)
		return session.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: [T].self, decoder: decoder)
			.eraseToAnyPublisher()
	}
	
	func first<T: RemoteResource>(pathPrefix: String? = nil) -> AnyPublisher<T?, Error> {
		let url = buildUrl(for: T.self, prefix: pathPrefix)
		return session.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: [T].self, decoder: decoder)
			.map(\.first)
			.eraseToAnyPublisher()
	}
	
	func find<T: UniqueRemoteResource>(identifier: T.ID, pathPrefix: String? = nil) -> AnyPublisher<T, Error> {
		let url = buildUrl(for: T.self, prefix: pathPrefix).appendingPathComponent(String(describing: identifier))
		return session.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: T.self, decoder: decoder)
			.eraseToAnyPublisher()
	}
	
	func create<T: Encodable, U: RemoteResource>(_ body: T, pathPrefix: String? = nil) -> AnyPublisher<U, Error> {
		let url = buildUrl(for: U.self, prefix: pathPrefix)
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		do {
			request.httpBody = try encoder.encode(body)
			return session.dataTaskPublisher(for: request)
				.map(\.data)
				.decode(type: U.self, decoder: decoder)
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
			return session.dataTaskPublisher(for: request)
				.map(\.data)
				.decode(type: T.self, decoder: decoder)
				.eraseToAnyPublisher()
		} catch {
			return Fail(outputType: T.self, failure: error).eraseToAnyPublisher()
		}
	}
	
	func delete<T: UniqueRemoteResource>(_ resource: T, pathPrefix: String? = nil) -> AnyPublisher<Void, URLError> {
		delete(type(of: resource), identifier: String(describing: resource.id), pathPrefix: pathPrefix)
	}
	
	func delete<T: RemoteResource>(_ type: T.Type, identifier: String, pathPrefix: String? = nil) -> AnyPublisher<(), URLError> {
		let url = buildUrl(for: type, prefix: pathPrefix)
		var request = URLRequest(url: url)
		request.httpMethod = "DELETE"
		return session.dataTaskPublisher(for: request)
			.map { _ in }
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
	
}
