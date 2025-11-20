// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModifierSwift",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "modifier-swift",
            targets: ["CLI"]
        ),
        .library(
            name: "ModifierSwiftCore",
            targets: ["Core"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0")
    ],
    targets: [
        // Core library - contains parser, analyzer, and generator
        .target(
            name: "Core",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ],
            path: "Sources/Core"
        ),
        
        // CLI executable
        .executableTarget(
            name: "CLI",
            dependencies: [
                "Core",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CLI"
        ),
        
        // Tests for Core
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests/CoreTests"
        ),
        
        // Integration tests
        .testTarget(
            name: "IntegrationTests",
            dependencies: ["Core"],
            path: "Tests/IntegrationTests"
        )
    ]
)
