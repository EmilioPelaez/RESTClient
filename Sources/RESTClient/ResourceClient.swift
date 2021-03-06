//
//  RESTClient.swift
//  RESTClient
//
//  Created by Emilio Peláez on 27/10/20.
//

import Foundation
import Combine

open class ResourceClient: HTTPClient, TopLevelDecoder {
	
	open var baseUrl: URL
	open var router: Router
	open var updateMethod: HTTPMethod
	open var encoder: JSONEncoder
	open var decoder: JSONDecoder
	
	open var requestConfiguration: (inout URLRequest) -> Void = { _ in }
	
	public init(baseUrl: URL, router: Router = BasicRouter(), updateMethod: HTTPMethod = .PUT, session: URLSession = .shared, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
		self.baseUrl = baseUrl
		self.router = router
		self.updateMethod = updateMethod
		self.encoder = encoder
		self.decoder = decoder
		
		super.init(session: session)
	}
	
	open func all<Resource: Decodable>(_ type: Resource.Type, router: Router? = nil) -> AnyPublisher<[Resource], Error> {
		let url = (router ?? self.router).url(for: type, baseURL: baseUrl)
		return performRequest(for: url, method: .GET, configuration: requestConfiguration)
			.map(\.data)
			.decode(type: [Resource].self, decoder: self)
			.eraseToAnyPublisher()
	}
	
	open func first<Resource: Decodable>(_ type: Resource.Type, router: Router? = nil) -> AnyPublisher<Resource?, Error> {
		let url = (router ?? self.router).url(for: type, baseURL: baseUrl)
		return performRequest(for: url, method: .GET, configuration: requestConfiguration)
			.map(\.data)
			.decode(type: [Resource].self, decoder: self)
			.map(\.first)
			.eraseToAnyPublisher()
	}
	
	open func find<Resource: UniqueRemoteResource>(_ type: Resource.Type, identifier: Resource.ID, router: Router? = nil) -> AnyPublisher<Resource, Error> {
		let url = (router ?? self.router).url(for: type, identifier: identifier, baseURL: baseUrl)
		return performRequest(for: url, method: .GET, configuration: requestConfiguration)
			.map(\.data)
			.decode(type: Resource.self, decoder: self)
			.eraseToAnyPublisher()
	}
	
	open func create<Body: Encodable, Resource: Decodable>(_ body: Body, receive: Resource.Type, router: Router? = nil) -> AnyPublisher<Resource, Error> {
		let url = (router ?? self.router).url(for: type(of: body), baseURL: baseUrl)
		return performRequest(for: url, method: .POST, body: try HTTPBody(body, encoder: encoder), configuration: requestConfiguration)
			.map(\.data)
			.decode(type: Resource.self, decoder: self)
			.eraseToAnyPublisher()
	}
	
	open func create<Body: Encodable>(_ body: Body, router: Router? = nil) -> AnyPublisher<Void, Error> {
		let url = (router ?? self.router).url(for: type(of: body), baseURL: baseUrl)
		return performRequest(for: url, method: .POST, body: try HTTPBody(body, encoder: encoder), configuration: requestConfiguration)
			.map { _ in }
			.eraseToAnyPublisher()
	}
	
	open func update<Resource: UniqueRemoteResource>(_ resource: Resource, router: Router? = nil) -> AnyPublisher<Resource, Error> {
		let url = (router ?? self.router).url(for: resource, baseURL: baseUrl)
		return performRequest(for: url, method: updateMethod, body: try HTTPBody(resource, encoder: encoder), configuration: requestConfiguration)
			.map(\.data)
			.decode(type: Resource.self, decoder: self)
			.eraseToAnyPublisher()
	}
	
	open func updateVoid<Resource: UniqueRemoteResource>(_ resource: Resource, router: Router? = nil) -> AnyPublisher<Void, Error> {
		let url = (router ?? self.router).url(for: resource, baseURL: baseUrl)
		return performRequest(for: url, method: updateMethod, body: try HTTPBody(resource, encoder: encoder), configuration: requestConfiguration)
			.map { _ in }
			.eraseToAnyPublisher()
	}
	
	open func delete<Resource: UniqueRemoteResource>(_ resource: Resource, router: Router? = nil) -> AnyPublisher<Void, Error> {
		delete(type(of: resource), identifier: resource.id, router: router)
	}
	
	open func delete<Resource: UniqueRemoteResource>(_ type: Resource.Type, identifier: Resource.ID, router: Router? = nil) -> AnyPublisher<(), Error> {
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
