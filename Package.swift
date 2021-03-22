// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "RESTClient",
	platforms: [
		.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)
	],
	products: [
		.library(
			name: "RESTClient",
			targets: ["RESTClient"]),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "RESTClient",
			dependencies: []),
		.testTarget(
			name: "RESTClientTests",
			dependencies: ["RESTClient"]),
	]
)
