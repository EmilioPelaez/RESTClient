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
