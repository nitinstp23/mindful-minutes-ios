// swift-tools-version: 5.9
// Package.swift for SwiftLint integration

import PackageDescription

let package = Package(
    name: "MindfulMinutes",
    platforms: [
        .iOS(.v17)
    ],
    products: [],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.54.0")
    ],
    targets: []
)