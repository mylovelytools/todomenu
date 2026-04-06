// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "TodoMenu",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "TodoMenuApp", targets: ["TodoMenuApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.7.0")
    ],
    targets: [
        .executableTarget(
            name: "TodoMenuApp",
            path: "Sources/TodoMenuApp"
        ),
        .testTarget(
            name: "TodoMenuAppTests",
            dependencies: [
                "TodoMenuApp",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/TodoMenuAppTests"
        )
    ]
)
