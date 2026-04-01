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
    targets: [
        .executableTarget(
            name: "TodoMenuApp",
            path: "Sources/TodoMenuApp"
        ),
        .testTarget(
            name: "TodoMenuAppTests",
            dependencies: ["TodoMenuApp"],
            path: "Tests/TodoMenuAppTests"
        )
    ]
)
