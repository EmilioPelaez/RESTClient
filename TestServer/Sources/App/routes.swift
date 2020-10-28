import Vapor

enum AppError: Error {
	case encodeFailure
	case missingBody
	case missingId
	case invalidId
}

func routes(_ app: Application) throws {
	let values = (1...10)
	
	app.get { req in
		return "Server is up"
	}
	
	func encodedString<T: Encodable>(_ object: T) throws -> String {
		let data = try JSONEncoder().encode(object)
		guard let string = String(data: data, encoding: .utf8) else {
			throw AppError.encodeFailure
		}
		return string
	}
	
	func decode<T: Decodable>(_ type: T.Type, from request: Request) throws -> T {
		guard let buffer = request.body.data else {
			throw AppError.missingBody
		}
		return try JSONDecoder().decode(T.self, from: buffer)
	}
	
	app.get("objects") { req -> String in
		let objects = values.map { Object(id: $0, value: "Hello") }
		return try encodedString(objects)
	}
	
	app.get(["objects", ":id"]) { req -> String in
		guard let idString = req.parameters.get("id") else {
			throw AppError.missingId
		}
		guard let id = Int(idString) else {
			throw AppError.invalidId
		}
		guard values.contains(id) else {
			throw AppError.invalidId
		}
		let object = Object(id: id, value: "Hello")
		return try encodedString(object)
	}
	
	app.post("objects") { req -> String in
		let newObject = try decode(NewObject.self, from: req)
		let object = Object(id: 11, value: newObject.value)
		return try encodedString(object)
	}
	
	app.put(["objects", ":id"]) { req -> String in
		guard let idString = req.parameters.get("id") else {
			throw AppError.missingId
		}
		guard let id = Int(idString) else {
			throw AppError.invalidId
		}
		guard values.contains(id) else {
			throw AppError.invalidId
		}
		let object = try decode(NewObject.self, from: req)
		return try encodedString(object)
	}
	
	app.delete(["objects", ":id"]) { req -> String in
		guard let idString = req.parameters.get("id") else {
			throw AppError.missingId
		}
		guard let id = Int(idString) else {
			throw AppError.invalidId
		}
		guard values.contains(id) else {
			throw AppError.invalidId
		}
		return ""
	}
}