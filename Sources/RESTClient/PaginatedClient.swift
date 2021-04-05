//
//  File.swift
//  
//
//  Created by Emilio Peláez on 5/4/21.
//

import Foundation
import Combine

class PaginatedClient<Page: Decodable>: ResourceClient {
	
	enum PaginatedClientError: Error {
		case invalidUrl
	}
	
	let pageKey: String
	let pageSizeKey: String
	
	public init(baseUrl: URL, pageKey: String = "page", pageSizeKey: String = "pageSize", router: Router = BasicRouter(), updateMethod: HTTPMethod = .PUT, session: URLSession = .shared, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
		self.pageKey = pageKey
		self.pageSizeKey = pageSizeKey
		super.init(baseUrl: baseUrl, router: router, updateMethod: updateMethod, session: session, encoder: encoder, decoder: decoder)
	}
	
	func page<Resource: Decodable>(_ type: Resource.Type, router: Router? = nil, page: Int, pageSize: Int) -> AnyPublisher<PaginatedResponse<Page, [Resource]>, Error> {
		let url = (router ?? self.router).url(for: type, baseURL: baseUrl)
		guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			return Fail(error: PaginatedClientError.invalidUrl).eraseToAnyPublisher()
		}
		components.queryItems = [
			URLQueryItem(name: pageKey, value: "\(page)"),
			URLQueryItem(name: pageSizeKey, value: "\(pageSize)")
		]
		guard let finalUrl = components.url else {
			return Fail(error: PaginatedClientError.invalidUrl).eraseToAnyPublisher()
		}
		return performRequest(for: finalUrl, method: .GET, configuration: requestConfiguration)
			.map(\.data)
			.decode(type: PaginatedResponse<Page, [Resource]>.self, decoder: self)
			.eraseToAnyPublisher()
	}
	
}

struct PaginatedResponse<Page: Decodable, Results: Decodable>: Decodable {
	let page: Page
	let results: Results
}
