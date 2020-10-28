//
//  RemoteResource.swift
//  RESTClient
//
//  Created by Emilio Peláez on 27/10/20.
//

import Foundation

public protocol RemoteResource: Codable {
	static var path: String { get }
}

extension RemoteResource {
	public static var path: String { String(describing: self).lowercased() + "s" }
}
