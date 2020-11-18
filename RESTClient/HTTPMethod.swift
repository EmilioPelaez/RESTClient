//
//  HTTPMethod.swift
//  RESTClient
//
//  Created by Emilio Peláez on 18/11/20.
//

import Foundation

public enum HTTPMethod {
	case GET
	case POST
	case PUT
	case PATCH
	case DELETE
	case custom(String)
}

extension HTTPMethod: CustomStringConvertible {
	public var description: String {
		switch self {
		case .GET: return "GET"
		case .POST: return "POST"
		case .PUT: return "PUT"
		case .PATCH: return "PATCH"
		case .DELETE: return "DELETE"
		case .custom(let method): return method
		}
	}
}
