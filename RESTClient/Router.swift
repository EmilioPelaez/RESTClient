//
//  Router.swift
//  RESTClient
//
//  Created by Emilio Peláez on 18/11/20.
//

import Foundation

public protocol Router {
	//	Used for creating URLs that don't specify an object identifier
	func url<T>(for type: T.Type, baseURL: URL) -> URL
	func url<T: RemoteResource>(for type: T.Type, baseURL: URL) -> URL
	
	//	Used for creating URLs that DO specify an object identifier
	func url<T: UniqueRemoteResource>(for object: T, baseURL: URL) -> URL
	func url<T: UniqueRemoteResource>(for type: T.Type, identifier: T.ID, baseURL: URL) -> URL
}

extension Router {
	
	public func url<T>(for type: T.Type, baseURL: URL) -> URL {
		baseURL.appendingPathComponent(String(describing: type).lowercased() + "s")
	}
	
	public func url<T: RemoteResource>(for type: T.Type, baseURL: URL) -> URL {
		baseURL.appendingPathComponent(type.path)
	}
	
	public func url<T: UniqueRemoteResource>(for object: T, baseURL: URL) -> URL {
		url(for: T.self, identifier: object.id, baseURL: baseURL)
	}
	
	public func url<T: UniqueRemoteResource>(for type: T.Type, identifier: T.ID, baseURL: URL) -> URL {
		url(for: T.self, baseURL: baseURL).appendingPathComponent(String(describing: identifier))
	}
	
}

public class BasicRouter: Router {
	public init() {}
}
