//
//  RESTClient.swift
//  RESTClient
//
//  Created by Emilio Peláez on 27/10/20.
//

import Foundation
import Combine

open class RESTClient: HTTPClient, TopLevelDecoder {
	
	public let baseUrl: URL
	public let router: Router
	public let encoder: JSONEncoder
	public let decoder: JSONDecoder
	
	public init(baseUrl: URL, router: Router = BasicRouter(), session: URLSession = .shared, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
		self.baseUrl = baseUrl
		self.router = router
		self.encoder = encoder
		self.decoder = decoder
		
		super.init(session: session)
	}
	
	open func all<T: Decodable>(_ type: T.Type, router: Router? = nil) -> AnyPublisher<[T], Error> {
		let url = (router ?? self.router).url(for: type, baseURL: baseUrl)
		return performRequest(for: url, method: .GET, configuration: requestConfiguration)
			.map(\.data)
			.decode(type: [T].self, decoder: self)
			.eraseToAnyPublisher()
	}
	
	open func first<T: Decodable>(_ type: T.Type, router: Router? = nil) -> AnyPublisher<T?, Error> {
		let url = (router ?? self.router).url(for: type, baseURL: baseUrl)
		return performRequest(for: url, method: .GET, configuration: requestConfiguration)
			.map(\.data)
			.decode(type: [T].self, decoder: self)
			.map(\.first)
			.eraseToAnyPublisher()
	}
	
	open func find<T: UniqueRemoteResource>(_ type: T.Type, identifier: T.ID, router: Router? = nil) -> AnyPublisher<T, Error> {
		let url = (router ?? self.router).url(for: type, identifier: identifier, baseURL: baseUrl)
		return performRequest(for: url, method: .GET, configuration: requestConfiguration)
			.map(\.data)
			.decode(type: T.self, decoder: self)
			.eraseToAnyPublisher()
	}
	
	open func create<T: Encodable, U: Decodable>(_ body: T, receive: U.Type, router: Router? = nil) -> AnyPublisher<U, Error> {
		let url = (router ?? self.router).url(for: type(of: body), baseURL: baseUrl)
		return performRequest(for: url, method: .POST, body: try HTTPBody(body, encoder: encoder), configuration: requestConfiguration)
			.map(\.data)
			.decode(type: U.self, decoder: self)
			.eraseToAnyPublisher()
	}
	
	open func update<T: UniqueRemoteResource>(_ resource: T, router: Router? = nil) -> AnyPublisher<T, Error> {
		let url = (router ?? self.router).url(for: resource, baseURL: baseUrl)
		return performRequest(for: url, method: .PUT, body: try HTTPBody(resource, encoder: encoder), configuration: requestConfiguration)
			.map(\.data)
			.decode(type: T.self, decoder: self)
			.eraseToAnyPublisher()
	}
	
	open func delete<T: UniqueRemoteResource>(_ resource: T, router: Router? = nil) -> AnyPublisher<Void, Error> {
		delete(type(of: resource), identifier: resource.id, router: router)
	}
	
	open func delete<T: UniqueRemoteResource>(_ type: T.Type, identifier: T.ID, router: Router? = nil) -> AnyPublisher<(), Error> {
		let url = (router ?? self.router).url(for: type, identifier: identifier, baseURL: baseUrl)
		return performRequest(for: url, method: .DELETE, configuration: requestConfiguration)
			.map { _ in  }
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	open func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
		try decoder.decode(type, from: data)
	}
	
}
